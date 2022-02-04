/**
 * ENEL599 Assignment 2 
 *
 * Single channel Analog Oscilloscope using Arduino.
 *
 * This sketch receives data measured by the Arduino
 * and displays it as an animated graph.
 *
 * It is also possible to set a threshold that makes an LED turn on 
 * when the signal measured by the Arduino exceeds it.
 *
 * @author  Stefan Marks
 * @author  Leegan Te
 */


// import the serial communication library and Java Swing
import processing.serial.*;
import javax.swing.*;

// the serial communication object
Serial serial;

// the graph canvas
Graph graph;


/**
 * Sets up the program
 */
void setup()
{
  size(1024, 400);
  frameRate(60);

  // (automatically) choose a serial port 
  // You can replace the method parameter by the port you are using most often 
  // to avoid the dialog popping up, e.g., "COM3" or "/dev/cu.usbserial1432".
  serial = chooseSerialPort("insert your portname here");

  // nothing found or selected > doesn't make sense to run program
  if ( serial == null ) exit();

  // create Graph object
  graph = new Graph("Analog In", new Rectangle(0, 0, width-1, height-1), color(255, 0, 0), 0, 1000, 200);

  // give Arduino 2s to reset and then immediately update threshold
  delay(2000);
  sendThreshold(graph.getThreshold());
}



/**
 * Chooses a serial port, either by looking for a default port name,
 * or by prompting te user to select one from a dialog box.
 *
 * @param defaultSerialPort  Name of the serial port to look for at first
 * 
 * @return  the serial port found or selected by the user, 
 *          or <code>null</code> if no port was found and selected
 */
Serial chooseSerialPort(String defaultSerialPort)
{
  // create selection list of serial communication ports
  String[] ports            = Serial.list();
  String   selectedPortName = "";
  Serial   serialPort       = null;

  // try default serial port first
  for ( String port : ports )
  {
    if ( port.equals(defaultSerialPort) )
    {
      selectedPortName = port; // found it
      break;
    }
  }

  // did not find default port choice > show selection dialog
  if ( selectedPortName.isEmpty() )
  {
    JComboBox cbxPortList = new JComboBox(ports);

    // ask user to select one
    int dialogResult = JOptionPane.showConfirmDialog(
      null, 
      cbxPortList, 
      "Select a Serial Communication Port", 
      JOptionPane.OK_CANCEL_OPTION);

    // did user press "OK"?  
    if ( dialogResult == JOptionPane.OK_OPTION )
    {
      selectedPortName = (String) cbxPortList.getSelectedItem();
    }
  }

  // so what's the final result?
  if ( !selectedPortName.isEmpty() )
  {
    // port selected > initialise selected serial port with 115200 baud
    serialPort = new Serial(this, selectedPortName, 115200);
  } else
  {
    System.exit(0);
  }

  return serialPort;
}


/**
 * Called to draw a single frame.
 */
void draw()
{
  receiveMeasurement();

  // clear screen and draw graphs
  background(100);
  graph.draw();
}


/**
 * Called when the mouse is clicked on the screen.
 */
void mousePressed()
{
  if ( graph.handleMousePressed(mouseX, mouseY) )
  {
    int t = graph.getThreshold();
    println(graph.getTitle() + " threshold changed to " + t);

    sendThreshold(t);
  }
}


/**
 * Called to check the serial port for received data.
 * If data was received, parse it and pass it on to the graph.
 */
void receiveMeasurement()
{
  while (serial.available() >=2 ) // Returns the number of bytes available.
  {
    int hb = serial.read(); //Returns a number between 0 ad 255 for the next byte waiting in buffer.
    int lb = serial.read(); //Returns a number between 0 ad 255 for the next byte waiting in buffer.

    int potValue = (hb << 8) | lb;

    graph.pushValue(potValue);
  }
  // {
  //   int value = 0;
  //  
  //   // receive data and store in "value" variable
  //   your code here
  //     
  //   // add measurement to the graph
  //   graph.pushValue(value);
  // }

  // ---------------------------------------------------------------
}


/**
 * Called to change the threshold value on the Arduino.
 *
 * @param newThreshold  the new threshold to send to the Arduino
 */
void sendThreshold(int newThreshold)
{
  int n_highByte = newThreshold >> 8 &0xFF; //makes all but the last 8 bits into a 0
  int n_lowByte = newThreshold & 0xFF;      // 0xFF is 00000000000000000000000011111111
  serial.write(n_highByte); // writes the variable new highByte serial
  serial.write(n_lowByte);  // writes the varaible new lowByte serial
}
