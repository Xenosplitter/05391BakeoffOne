import java.awt.AWTException;
import java.awt.Rectangle;
import java.awt.Robot;
import java.util.ArrayList;
import java.util.Collections;
import processing.core.PApplet;

//when in doubt, consult the Processsing reference: https://processing.org/reference/
int Y_AXIS = 1;
int X_AXIS = 2;
int margin = 200; //set the margin around the squares
final int padding = 50; // padding between buttons and also their width/height
final int buttonSize = 40; // padding between buttons and also their width/height
ArrayList<Integer> trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
int trialNum = 0; //the current trial number (indexes into trials array above)
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
int hits = 0; //number of successful clicks
int misses = 0; //number of missed clicks
boolean lastClickWasError = false;
Robot robot; //initalized in setup

// Program Color Scheme
color current_color = color(57, 255, 20); // green
color next_color = color(231,180,22); // traffic light yellow
color outline_color = color(255, 255, 255); // white

int numRepeats = 3; //sets the number of times each button repeats in the test

void setup()
{
  size(700, 700); // set the size of the window
  //noCursor(); //hides the system cursor if you want
  noStroke(); //turn off all strokes, we're just using fills here (can change this if you want)
  textFont(createFont("Arial", 16)); //sets the font to Arial size 16
  textAlign(CENTER);
  frameRate(80); //originally 60
  ellipseMode(CENTER); //ellipses are drawn from the center (BUT RECTANGLES ARE NOT!)
  //rectMode(CENTER); //enabling will break the scaffold code, but you might find it easier to work with centered rects

  try {
    robot = new Robot(); //create a "Java Robot" class that can move the system cursor
  } 
  catch (AWTException e) {
    e.printStackTrace();
  }

  //===DON'T MODIFY MY RANDOM ORDERING CODE==
  for (int i = 0; i < 16; i++) //generate list of targets and randomize the order
      // number of buttons in 4x4 grid
    for (int k = 0; k < numRepeats; k++)
      // number of times each button repeats
      trials.add(i);

  Collections.shuffle(trials); // randomize the order of the buttons
  System.out.println("trial order: " + trials);
  
  frame.setLocation(0,0); // put window in top left corner of screen (doesn't always work)
}


void draw()
{
  background(0); //set background to black

  //draw finale
  if (trialNum >= trials.size()) //check to see if test is over
  {
    float timeTaken = (finishTime-startTime) / 1000f;
    float penalty = constrain(((95f-((float)hits*100f/(float)(hits+misses)))*.2f),0,100);
    fill(255); //set fill color to white
    //write to screen (not console)
    text("Finished!", width / 2, height / 2); 
    text("Hits: " + hits, width / 2, height / 2 + 20);
    text("Misses: " + misses, width / 2, height / 2 + 40);
    text("Accuracy: " + (float)hits*100f/(float)(hits+misses) +"%", width / 2, height / 2 + 60);
    text("Total time taken: " + timeTaken + " sec", width / 2, height / 2 + 80);
    text("Average time for each button: " + nf((timeTaken)/(float)(hits+misses),0,3) + " sec", width / 2, height / 2 + 100);
    text("Average time for each button + penalty: " + nf(((timeTaken)/(float)(hits+misses) + penalty),0,3) + " sec", width / 2, height / 2 + 140);
    text("Want to test again? Press \'R\'", width / 2, height / 2 + 180);
    return; //return, nothing else to do now test is over
  }

  //draw text
  fill(255); //set fill color to white
  //text((trialNum + 1) + " of " + trials.size(), 40, 20); //display what trial the user is on
  textSize(20);
  if (trialNum == 0) {
    text("Left click or press SPACE when hovering over the green box!", width/2, 70);
  }
  text("Button " + (trialNum + 1) + " of " + trials.size(), width/2, 160); //display what trial the user is on
  text("Hits: " + hits, width / 2, 100);
  text("Misses: " + misses, width / 2, 130);
  
  //draw boxes
  if (lastClickWasError)
  {
    fill(255, 0, 0); // Red
    text("Misses: " + misses, width / 2, 130);
    fill(255); // reset to white
  }
  fill(255);
  noStroke();
  for (int i = 0; i < 16; i++)// for all button
        {
            Rectangle btn = getButtonLocation(i);
            //Draw border around buttton if mouse is hovering over
            if (cursorInButton(btn))
            {
                drawBorder(btn);
            }
            drawButton(btn, i); //draw button
        }  

  //cursor
  stroke(239, 240, 70);
  strokeWeight(1);
  fill(255, 70, 184, 200); //neon pink
  ellipse(mouseX, mouseY, 10, 10); //draw user cursor as a circle with a diameter of 20 --> 10
  noStroke();
}

void mousePressed() // test to see if hit was in target!
{
  mouseX = constrain(mouseX, margin-padding/2, width-margin+padding/2);
  mouseY = constrain(mouseY, margin-padding/2, width-margin+padding/2);
  
  if (trialNum >= trials.size()) //if task is over, just return
    return;

  if (trialNum == 0) //check if first click, if so, start timer
    startTime = millis();

  if (trialNum == trials.size() - 1) //check if final click
  {
    finishTime = millis();
    //write to terminal some output. Useful for debugging too.
    println("we're done!");
  }

  Rectangle bounds = getButtonLocation(trials.get(trialNum));

 //check to see if mouse cursor is inside button 
  if ((mouseX >= bounds.x - padding/2 && mouseX <= bounds.x + bounds.width + padding/2) && (mouseY >= bounds.y - padding/2 && mouseY <= bounds.y + bounds.height + padding/2)) // test to see if hit was within bounds
  {
    System.out.println("HIT! " + trialNum + " " + (millis() - startTime)); // success
    hits++; 
    lastClickWasError = false;
  } 
  else
  {
    System.out.println("MISSED! " + trialNum + " " + (millis() - startTime)); // fail
    misses++;
    lastClickWasError = true;
  }

  trialNum++; //Increment trial number

  //in this example code, we move the mouse back to the middle
  //robot.mouseMove(width/2, (height)/2); //on click, move cursor to roughly center of window!
}  

//probably shouldn't have to edit this method
Rectangle getButtonLocation(int i) //for a given button ID, what is its location and size
{
   int x = (i % 4) * (padding + buttonSize) + margin;
   int y = (i / 4) * (padding + buttonSize) + margin;
   return new Rectangle(x, y, buttonSize, buttonSize);
}

//you can edit this method to change how buttons appear
void drawButton(Rectangle bounds, int i)
{
    if (trials.get(trialNum) == i) {
        // see if current button is the target
        if ((trialNum < trials.size()-1) && (trials.get(trialNum+1) == i)) {
            // indicate repeated current/next square with gradient
            setGradient(bounds.x, bounds.y, buttonSize, buttonSize, current_color, next_color, X_AXIS);
        } else {
          fill(current_color);
        }
    } else if ((trialNum < trials.size()-1) && (trials.get(trialNum+1) == i)) {
        // see if current button is next target
        fill(next_color);
    } else {
        fill(200); // if not, fill gray
    }

    rect(bounds.x, bounds.y, bounds.width, bounds.height); //draw button
}

void mouseMoved()
{
   //can do stuff everytime the mouse is moved (i.e., not clicked)
   //https://processing.org/reference/mouseMoved_.html
   mouseX = constrain(mouseX, margin-padding/2, width-margin+padding/2);
   mouseY = constrain(mouseY, margin-padding/2, width-margin+padding/2);
}

void mouseDragged()
{
  //can do stuff everytime the mouse is dragged
  //https://processing.org/reference/mouseDragged_.html
}

void keyPressed() 
{
  //can use the keyboard if you wish
  //https://processing.org/reference/keyTyped_.html
  //https://processing.org/reference/keyCode.html
  if (key == ' ')
  {
    mousePressed();
  }
  // Reset test (only available after completion)
  else if (key == 'r' && trialNum >= trials.size())
  {
    // reset every value to initial
    trials = new ArrayList<Integer>(); //contains the order of buttons that activate in the test
    trialNum = 0; //the current trial number (indexes into trials array above)
    startTime = 0; // time starts when the first click is captured
    finishTime = 0; //records the time of the final click
    hits = 0; //number of successful clicks
    misses = 0; //number of missed clicks 
    setup();
  }
}

void drawBorder(Rectangle bounds)
{
    fill(outline_color);
    rect(bounds.x - 5, bounds.y - 5, bounds.width + 10, bounds.height + 10); //draw border
}

// Returns true if cursor location falls within a given button, including padding 
boolean cursorInButton(Rectangle bounds)
{
    return (mouseX > bounds.x -padding/2 && mouseX < bounds.x + bounds.width + padding/2)
        && (mouseY > bounds.y -padding/2 && mouseY < bounds.y + bounds.height + padding/2);
}

int getButtonX(int button) {
  int i = button;
  return (i % 4) * (padding + buttonSize) + margin + buttonSize/2;
}

int getButtonY(int button) {
  int i = button;
  return (i / 4) * (padding + buttonSize) + margin + buttonSize/2;
}

void setGradient(int x, int y, float w, float h, color c1, color c2, int axis ) {

  noFill();

  if (axis == Y_AXIS) {  // Top to bottom gradient
    for (int i = y; i <= y+h; i++) {
      float inter = map(i, y, y+h, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(x, i, x+w, i);
    }
  }  
  else if (axis == X_AXIS) {  // Left to right gradient
    for (int i = x; i <= x+w; i++) {
      float inter = map(i, x, x+w, 0, 1);
      color c = lerpColor(c1, c2, inter);
      stroke(c);
      line(i, y, i, y+h);
    }
  }
  noStroke();
}
