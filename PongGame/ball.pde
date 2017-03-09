class Ball {
  float x;
  float y;
  int diameter;

  float xSpeed;
  float ySpeed;

  float multiplier;

  boolean inBounds;

  Ball() {
    x = width/2;
    y = random(height/4, height/4*3);
    diameter = 8;

    multiplier = 1.5;

    xSpeed = -1.0;
    ySpeed = 1;

    inBounds = true;
  }

  void display() {
    fill(255);
    noStroke();
    rect(this.x, this.y, this.diameter, this.diameter);
  }

  void develop() {
    fill(255);
    noStroke();
    textSize(14);
    textAlign(CENTER);
    String displaySpeed = String.format("%.2f", multiplier);

    text("Ball Speed: " + displaySpeed, width/2, 25);
  }

  void move() {

    // detect if ball is in same xPos as paddle
    if (x-diameter/2 == playerA.x+playerA.w/2) {
      // if the paddle is at the same vertical location as ball
      if (y >= playerA.y-playerA.h/2 && y <= playerA.y+playerA.h/2) {
        inBounds = true;
        xSpeed = -xSpeed;
      } else {      
        if (restartGame) {
          inBounds = false;
        }
      }
    } else if (x-diameter/2 < playerA.x+playerA.w/2) {
      // ball past paddle
      if (endlessGame) {
        if (x <= 4) {
          println("player A missed");
          x = 5;
          xSpeed = 1;
          playerB.points++;
        }
      }
    }

    if (x+diameter/2 == playerB.x-playerB.w/2) {
      //if paddle at same vertical location as ball
      if (y >= playerB.y-playerB.h/2 && y <= playerB.y+playerB.h/2) {
        inBounds = true;
        xSpeed = -xSpeed;
      } else {      
        if (restartGame) {
          inBounds = false;
        }
      }
    } else if (x+diameter/2 > playerB.x-playerB.w/2) {
      // ball past paddle
      if (endlessGame) {
        if (x >= width-4) {
          println("player B missed");
          x = width-5;
          xSpeed = -1;
          playerA.points++;
        }
      }
    }

    if (y >= height-diameter/2 || y <= diameter/2) {
      ySpeed = -ySpeed;
    }

    if (inBounds) {
      x = x + (xSpeed*multiplier);
      y = y + (ySpeed*multiplier);
    } else {
      // player missed ball

      if (restartGame) {
        background(255, 0, 0);
        deadScreen = true;
        gameScreen = false;
        x = -15;
        y = -15;
        xSpeed = 0;
        ySpeed = 0;
      }
    }
  }

  void reset() {
    x = width/2;
    y = random(height/4, height/4*3);

    //float direction[] = {-0.5,0.5};
    //int tempSpeed = direction[float(random(0,1.5))];
    //println(tempSpeed);

    xSpeed = -1.0;
    ySpeed = 1;

    inBounds = true;
  }
}