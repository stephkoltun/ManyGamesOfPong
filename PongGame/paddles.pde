class Paddle {
  boolean known;
  String ctrl;
  String name;
  
  int points;
  
  int x;
  float y;
  int w;
  int h;
  
  int time;
  
  boolean constMove;
  
  int increment; 
  int adjIncrement;
  int upSpeed;
  int dnSpeed;
  
  // for controller C
  float ambientValue;
  
  // for controller E
  int prevSlideValue;
  int swipeStart;
  int swipeEnd;
  
  // for controller F
  boolean sequential;
  boolean prevValueOk;
  int prevForwardValue;
  int prevBackValue;
  int positionCounter;
  int positionsSeq[] = {300,350,400,450,500,550,600,550,500,450,400,350,300,250,200,150,100,50,0,50,100,150,200,250};
  int positionsNon[] = {200,300,50,400,350,450,550,0,100, 250, 600,150,500};
  
  
  Paddle() {
    w = 6;
    h = height/10;
    x = width/2;
    y = height/2;
    
    points = 0;

    constMove = false;
    increment = 0;
    
    adjIncrement = 0;
    
    time = 0;
    
    upSpeed = 0;
    dnSpeed = 0;
    
    //controller C
    ambientValue = 0;
    
    //controller E
    prevSlideValue = 0;
    
    // controller F
    sequential = true;
    positionCounter = 0;
    prevValueOk = true;
    prevBackValue = 0;
    prevForwardValue = 0;
    
    ctrl = "";
    name = "";
    known = false;
  }

  void display() {
    fill(255);
    noStroke();
    rect(x, y, w, h);
  }
  
  void develop() {
    fill(255);
    noStroke();
    textSize(12);
    if (name.equals("Player A")) {
      textAlign(LEFT);
      text(name, 40, 25);
      int displaySpeed = adjIncrement + increment;
      text("speed: " + displaySpeed, 40, 40);
    }
    
    if (name.equals("Player B")) {
      textAlign(RIGHT);
      text(name, width-40, 25);
      int displaySpeed = adjIncrement + increment;
      text("speed: " + displaySpeed, width-40, 40);
    }
    
  }

  void move() {
    // detect if mouse is outside vertical canvas dims
    if (y > height) {
      y = height;
    } else if (y < 0) {
      y = 0;
    } else {
      y = y - upSpeed*(adjIncrement+increment) + dnSpeed*(adjIncrement+increment);
    }
  }
}