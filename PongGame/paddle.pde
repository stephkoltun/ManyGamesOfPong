class Paddle {
  // identification
  String clientID;    // IP address of client
  String ctrl;        // name of controller
  int index;

  // game play
  int points;         // score

  // graphic display
  int x;
  float y;
  int w;
  int h;

  // behaviour
  boolean constMove;
  int increment; 
  int adjIncrement;    // for adjustments with keys
  int upSpeed;
  int dnSpeed;



  Paddle() {
    clientID = null;
    ctrl = null;
    index = -1;
    
    w = 6;           // thickness of paddle
    h = height/10;
    x = width/2;     // reset when paddles are added
    y = height/2;    // reset when paddles are added

    points = 0;

    constMove = false;
    increment = 0;
    adjIncrement = 0;
    upSpeed = 0;
    dnSpeed = 0;
  }

  void display() {
    fill(255);
    noStroke();
    rect(x, y, w, h);
  }
  
  void move() {
    // detect if paddle is outside vertical canvas dims
    if (y > height) {
      y = height;
    } else if (y < 0) {
      y = 0;
    } else {
      y = y - upSpeed*(adjIncrement+increment) + dnSpeed*(adjIncrement+increment);
    }
  }
  
  void develop() {
    fill(255);
    noStroke();
    textSize(12);
    if (index==0) {
      textAlign(LEFT);
      text("Player A", 40, 25);
      int displaySpeed = adjIncrement + increment;
      text("speed: " + displaySpeed, 40, 40);
    }
    
    if (index==1) {
      textAlign(RIGHT);
      text("Player B", width-40, 25);
      int displaySpeed = adjIncrement + increment;
      text("speed: " + displaySpeed, width-40, 40);
    }
    
  }
  
}