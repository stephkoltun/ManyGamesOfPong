
import processing.serial.*;

int counter = 0;

boolean introScreen = true;
boolean controllerScreen = false;
boolean gameScreen = false;
boolean deadScreen = false;

boolean developMode = false;

boolean endlessGame = true;
boolean restartGame = false;


int deadcounter = 0;




PFont myFont;
Ball ball;

Paddle playerA;
Paddle playerB;

Paddle[] players = new Paddle[2];

Serial[] myPorts = new Serial[3];  // Create a list of objects from Serial class
// last port is master



void openPort(int indexPort) {
  int portNum = 1+indexPort;
  String portName = Serial.list()[portNum];
  myPorts[indexPort] = new Serial(this, portName, 9600);

  myPorts[indexPort].clear();
  myPorts[indexPort].bufferUntil('\n');

  println("Port " + indexPort + " is open!");
}


void setup() { 
  size(700, 700);
  rectMode(CENTER);

  players[0] = new Paddle();
  players[1] = new Paddle();

  playerA = players[0];
  playerB = players[1];

  ball = new Ball();

  myFont = createFont("ApercuPro-Mono", 18);
  textFont(myFont);
} 

void draw() { 
  if (introScreen) {
    //background(50, 180, 170);
    background(0);
    textAlign(CENTER);
    fill(255);
    noStroke();
    textSize(18);
    text("24 Controllers for Pong", width/2, height/2);
    // rules

    textSize(18);
    if (counter >= 30) {
      fill(255);
      noStroke();
      text("18", (width/2-125), (height/2-20));
      stroke(255);
      strokeWeight(2);
      line((width/2-130), (height/2-15), (width/2-110), (height/2+3));
    } 
    
    if (counter >= 70) {
      fill(255);
      noStroke();
      text("12", (width/2-135), (height/2-40));
      stroke(255);
      strokeWeight(2);
      line((width/2-112), (height/2-20), (width/2-135), (height/2-32));
    }
    
    if (counter >= 130) {
      fill(255);
      noStroke();
      text("7", (width/2-140), (height/2-62));
      stroke(255);
      strokeWeight(2);
      line((width/2-120), (height/2-38), (width/2-145), (height/2-52));
      ellipseMode(CENTER);
      noFill();
      stroke(255);
      strokeWeight(3);
      ellipse(width/2-141,height/2-70,25,25);
    }

    if (counter >= 220) {
      textSize(13);
      fill(255);
      noStroke();
      text("1. Hit the ball back and forth by controlling your on-screen paddle.", width/2, height/2+50);
      text("2. Each player may use any paddle for the duration of a game.", width/2, height/2+70);
      text("3. Score a point when the other player fails to return the ball.", width/2, height/2+90);
      text("4. Use the shared knob to adjust the ball's speed.", width/2, height/2+110);
    }

    if (counter >= 600) {
      introScreen = false;
      controllerScreen = true;
    }
    counter++;
  } // end introscreen

  if (controllerScreen) {
    //background(190, 210, 40);
    background(0);
    textSize(18);
    textAlign(CENTER);
    fill(255);
    text("Plug in your controller\nand test it out!", width/2, height/2-50);
    text("When both players feel comfortable,\npress the red button to start", width/2, height/2+50); 

    if (myPorts[0] == null) {
      openPort(0);
    } else {
    }

    if (myPorts[1] == null) {
      openPort(1);
    }
    
    if (myPorts[2] == null) {
      openPort(2);
    }

    for (int i = 0; i < players.length; i++) {
      if (players[i].known) {
        // show the paddle
        players[i].display();
        if (players[i].constMove) {
          players[i].move();
        }
      }
    }
  }

  if (gameScreen) {
    
    if (endlessGame) {
      background(20, 40, 200);
    }
    
    if (restartGame) {
      background(125, 20, 125);
    }
    

    ball.display();
    ball.move();
    
    if (endlessGame) {
      // display points
      fill(255);
      noStroke();
      textSize(30);
      textAlign(RIGHT);
      text(playerA.points, width/2-50, height-20);
      textAlign(LEFT);
      text(playerB.points, width/2+50, height-20);
    }

    for (int i = 0; i < players.length; i++) {
      if (players[i].known) {
        // show the paddle
        players[i].display();
        if (players[i].constMove) {
          players[i].move();
        }
      }
    }
  }
  
  if (developMode) {
    ball.develop();
    playerA.develop();
    playerB.develop();
    
    if (endlessGame) {
      textSize(14);
      textAlign(CENTER);
      text("Endless Mode", width/2, 50);
    }
    
    if (restartGame) {
      textSize(14);
      textAlign(CENTER);
      text("Restart Mode", width/2, 50);
    }
  }
  

  if (deadScreen) {
    
    if (restartGame) {
      //background(20, 40, 200);
      background(255,0,0);
      
      textAlign(CENTER);
      textSize(42);

      if (deadcounter > 0 && deadcounter <= 30) {
        text("5", width/2, height/2);
      }
      
      if (deadcounter >= 31 && deadcounter <= 60) {
        text("4", width/2, height/2);
      }
  
      if (deadcounter >= 61 && deadcounter <= 90) {
        text("3", width/2, height/2);
      }
      
      if (deadcounter >= 91 && deadcounter <= 120) {
        text("2", width/2, height/2);
      }
      
      if (deadcounter >= 121 && deadcounter <= 150) {
        text("1", width/2, height/2);
      }
      
      if (deadcounter >= 151) {
        deadScreen = false;
        gameScreen = true;
        ball.reset();
        deadcounter = 0;
      }
      
      deadcounter++;
    }
  }
  
  //saveFrame("Capture-######.png");
}


void serialEvent(Serial thisPort) {

  // variable to hold the number of the port:
  int portNumber = -1;
  // iterate over the list of ports opened, and match the 
  // one that generated this event:
  for (int p = 0; p < myPorts.length; p++) {
    if (thisPort == myPorts[p]) {
      portNumber = p;
    }
  }


  // Read the serial buffer
  String inputString = thisPort.readString();

  if (inputString != null) {
    inputString = trim(inputString);
    String[] arrayInput = split(inputString, ",");
    
    // players control
    if (portNumber == 0 || portNumber == 1) {
      playerFunction(portNumber, arrayInput);
    }

    // global control
    if (portNumber == 2) {
      sharedController(portNumber, arrayInput);
    }
    
  }
}


void keyPressed() {
  
  // GAME MODE 
  if (key == 'g' || key == 'G') {
    endlessGame = !endlessGame;
    restartGame = !restartGame;
  }
  
  // DEVELOPMENT MODE
  if (key == 'd' || key == 'D') {
    developMode = !developMode;
  }
  
  // INCREMENT ADJUST FOR PLAYER A
  if (key == 'z' || key == 'Z') {
    playerA.adjIncrement++;
  }
  
  if (key == 'x' || key == 'X') {
    playerA.adjIncrement--;
  }
  
  // INCREMENT ADJUST FOR PLAYER B
  if (key == 'n' || key == 'N') {
    playerB.adjIncrement++;
  }
  
  if (key == 'm' || key == 'M') {
    playerB.adjIncrement--;
  }
  
  // controller screen
  if (key == 'q' || key == 'Q') {
    introScreen = false;
    controllerScreen = true;
    gameScreen = false;
    deadScreen = false;
  }
  
  // dead screen
  if (key == 'a' || key == 'A') {
    introScreen = false;
    controllerScreen = false;
    gameScreen = false;
    deadScreen = true;
  }

  // game screen
  if (key == 'p' || key == 'P') {
    introScreen = false;
    controllerScreen = false;
    deadScreen = false;
    gameScreen = true;
    ball.reset();
  }
}