class Ball {
  float x;
  float y;
  int diameter;

  float xSpeed;
  float ySpeed;

  float multiplier;

  Ball() {
    x = width/2;
    y = random(height/4, height/4*3);
    diameter = 8;

    multiplier = 3;   // this is really the speed

    xSpeed = -1.0;      // x direction
    ySpeed = 1;         // y direction
  }

  void display() {
    fill(255);
    noStroke();
    rect(this.x, this.y, this.diameter, this.diameter);
  }

  void move() {

    // change x direction
    if (((x-diameter/2) <= 0) || ((x+diameter/2) >= width)) {
      xSpeed = -xSpeed;
    }

    // change y direction
    if (y >= height-diameter/2 || y <= diameter/2) {
      ySpeed = -ySpeed;
    }

    // detect if ball was hit by paddles
    float paddleAEdge = players[0].x+players[0].w/2;
    if ((x >= (paddleAEdge - multiplier/2)) && (x <= (paddleAEdge + multiplier/2))) {
      // if the paddle is at the same vertical location as ball
      if (y >= players[0].y-players[0].h/2 && y <= players[0].y+players[0].h/2) {
        // change direction
        xSpeed = -xSpeed;
        // set paddle past outer boundary
        x = paddleAEdge+multiplier/2 + multiplier;
      } else {
        if (xSpeed == -1) {
          println("player A missed");
          players[1].points++;
        }
      }
    }

    float paddleBEdge = players[1].x-players[1].w/2;
    if ((x >= (paddleBEdge - multiplier/2)) && (x <= (paddleBEdge + multiplier/2))) {
      // if the paddle is at the same vertical location as ball
      if ((y >= players[1].y-players[1].h/2) && (y <= players[1].y+players[1].h/2)) {
    //    // change direction
        xSpeed = -xSpeed;
    //    // set paddle past outer boundary
        x = paddleBEdge-multiplier/2 - multiplier;
      } else {
        if (xSpeed == 1) {
          println("player B missed");
          players[0].points++;
        }
      }
    }

    // keep ball moving
    x = x + (xSpeed*multiplier);
    y = y + (ySpeed*multiplier);
  }

  void reset() {
    x = width/2;
    y = random(height/4, height/4*3);

    xSpeed = -1.0;
    ySpeed = 1;
  }

  void develop() {
    fill(255);
    noStroke();
    textSize(14);
    textAlign(CENTER);
    String displaySpeed = String.format("%.2f", multiplier);
    String posX = String.format("%.2f", x);
    String posY = String.format("%.2f", y);

    text("Ball Speed: " + displaySpeed, width/2, 25);
    text("Ball Position: " + posX + ", " + posY, width/2, 40);
  }
}