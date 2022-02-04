const int PIN_LDR = A0;
const int PIN_ledRed = 12; // red led connected to the 12 PWM on arduino
const int PIN_ledGreen = 11; // green led connected to the 11 PWM on arduino
int thredshold = 1000;

void setup()
{
  Serial.begin(115200);  // opens serial port, set data rate to 115200bps
  pinMode(PIN_LDR, INPUT);

  // intializes the LED as OUTPUT
  pinMode(PIN_ledRed, OUTPUT); 
  pinMode(PIN_ledGreen, OUTPUT);
}

void loop()
{
  int ldrValue = analogRead(PIN_LDR); // reads the LDR pin


  int hb = highByte (ldrValue);
  int lb = lowByte(ldrValue);

  Serial.write(hb); // sends the highByte value
  Serial.write(lb); //sends the lowByte value

  delay(10);       //pause for 10 milliseconds 

  if (Serial.available() >= 2) //reply when the data is received
  {
    int n_highByte = Serial.read(); //reads the incoming byte
    if (n_highByte <= 3)
    {
      int n_lowByte = Serial.read();  //reads the incoming byte
      int n_thredshold = (n_highByte << 8 | n_lowByte);
      thredshold = n_thredshold;
    }
  }
  if (ldrValue >= thredshold)
  {
    digitalWrite(PIN_ledRed, HIGH);
    digitalWrite(PIN_ledGreen, LOW);  // turns off the green led
  }
  else
  {
    digitalWrite(PIN_ledRed, LOW); // turns off the red led
    digitalWrite(PIN_ledGreen, HIGH);
  }
}
