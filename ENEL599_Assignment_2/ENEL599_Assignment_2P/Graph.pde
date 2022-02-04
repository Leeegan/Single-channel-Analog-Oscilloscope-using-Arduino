/**
 * Class for an animated 2D graph of values scrolling right.
 * By clicking into the graph, a new threshold can be set.
 *
 * @author Stefan Marks
 */

import java.awt.Rectangle; // class for managing a bounding rectangle

// constants for colours
final color GRAPH_BACKGROUND_COLOUR = color(0);
final color GRAPH_BORDER_COLOUR     = color(200);
final color GRAPH_TEXT_COLOUR       = color(255);

class Graph
{
  /**
   * Creates a new graph instance.
   *
   * @param title         the title of the graph
   * @param bounds        the boundaries/size of the graph
   * @param graphColour   the colour of the graph line
   * @param minValue      the minimum value to display at the bottom
   * @param maxValue      the maximum value to display at the top
   * @param tickInterval  interval at which to draw tickmarks and grid lines
   */
  public Graph(String title, Rectangle bounds, color graphColour, int minValue, int maxValue, int tickInterval)
  {
    this.title    = title;
    this.bounds   = bounds;
    this.colGraph = graphColour;
    
    this.minValue     = minValue;
    this.maxValue     = maxValue;
    this.tickInterval = tickInterval;
    
    // data buffer size = pixel width of graph
    buffer = new int[bounds.width];
    bufIdx = 0;
   
    // threshold = half way; 
    threshold = (maxValue + minValue) / 2;
  }
  
  
  /**
   * Pushes a new value into the graph.
   *
   * @param value  the new value for the graph
   */
  public void pushValue(int value)
  {
    // advance buffer pointer
    bufIdx = (bufIdx + 1) % buffer.length;
    // store new value
    buffer[bufIdx] = value;
  }


  /**
   * Draws the graph.
   */  
  public void draw()
  {
    float yPos;
    
    pushMatrix();
    translate(bounds.x, bounds.y);
    
    // clear graph area
    noStroke();
    rectMode(CORNER);
    fill(GRAPH_BACKGROUND_COLOUR);
    rect(0, 0, bounds.width, bounds.height);

    // draw the interval lines
    if ( tickInterval > 0 )
    {
      strokeWeight(1);
      stroke(lerpColor(GRAPH_BORDER_COLOUR, color(0), 0.5)); // in a darker colour
      for ( float y = minValue ; y <= maxValue ; y += tickInterval )
      {
        yPos = map(y, maxValue, minValue, 0, bounds.height); 
        line(0, yPos, bounds.width, yPos);
      }
    }
    
    // draw the threshold line
    strokeWeight(2);
    stroke(lerpColor(colGraph, color(0), 0.5)); // in a darker colour
    noFill();
    yPos = map(threshold, maxValue, minValue, 0, bounds.height); 
    line(0, yPos, bounds.width, yPos);
    
    // draw graph
    stroke(colGraph);
    strokeWeight(2);
    noFill();
    beginShape();
    int idx = bufIdx;
    for ( int x = 0 ; x < buffer.length ; x++ )
    {
      // convert value into Y coordinate, making sure it doesn't leave the bounds of the rectangle
      yPos = constrain(buffer[idx], minValue, maxValue);
      yPos = map(yPos, maxValue, minValue, 1, bounds.height - 1); 
      vertex(x, yPos);
      
      idx--; // every X step to the right is one step "into the buffer past"
      if ( idx < 0 ) { idx += buffer.length; } // negative buffer wraparound?
    }
    endShape();

    // print title
    fill(GRAPH_TEXT_COLOUR);    
    textSize(20);
    textAlign(CENTER);
    text(title, bounds.width / 2, 20);
    
    // print min/max values
    fill(GRAPH_TEXT_COLOUR);  
    textSize(12);
    textAlign(LEFT);
    text(nf(minValue, 0, 1), 2, bounds.height - 4);
    text(nf(maxValue, 0, 1), 2, 14);

    // graph border
    stroke(GRAPH_BORDER_COLOUR);
    strokeWeight(1);
    noFill();
    rect(0, 0, bounds.width, bounds.height);

    popMatrix();
  }


  /**
   * Called when a mouse button is pressed.
   * If the mouse is clicked within this graph, it will set a nre threshold value.
   * 
   * @param x  X position of mouse position in window coordinates
   * @param y  Y position of mouse position in window coordinates
   *
   * @return <code>true</code> if mouse press was handled, 
   *         <code>false</code> if not (e.g., clicked outside of window)
   */
  boolean handleMousePressed(int x, int y)
  {
    boolean handled = false;
    if ( bounds.contains(x, y) )
    {
      // mouse pressed within graph bounds -> calculate new thresshold
      threshold = (int) map(y, bounds.y + 1, bounds.y + bounds.height - 2, maxValue, minValue);
      threshold = constrain(threshold, minValue, maxValue);
      handled = true;
    }
    return handled;
  }


  /**
   * Gets the current threshold of the graph.
   *
   * @return  the current threshold of the graph
   */
  public int getThreshold()
  {
    return threshold;
  }


  /**
   * Gets the title of the graph.
   *
   * @return the title of the graph
   */
  public String getTitle()
  {
    return title;
  }
  
  
  
  private final String    title;
  
  private final Rectangle bounds;
  
  private final color     colGraph;
  
  private final int       minValue, maxValue, tickInterval;
  private       int       threshold;

  private final int[]     buffer;
  private       int       bufIdx;
}
