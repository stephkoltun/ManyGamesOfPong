void playerFunction(int indexVal, String[] inputArr) {
  String[] dataIn = inputArr;

  if (dataIn[0].equals("plugged")) {

    if (indexVal == 0) {
      playerA.name = "Player A";
    } else if (indexVal == 1) {
      playerB.name = "Player B";
    }

    println(players[indexVal].name + " plugged in");
    players[indexVal].known = false;

    //ask for name
    myPorts[indexVal].clear();
    myPorts[indexVal].write('a'); // ask for name
  } else if (dataIn[0].equals("hello")) {
    String ctrl = dataIn[1];

    if (ctrl != players[indexVal].ctrl) {
      // new controller has been selected
      println("new controller for " + players[indexVal].name);
      players[indexVal].ctrl = ctrl;
    }
    players[indexVal].time = millis(); // time initialized
    players[indexVal].known = true;
    players[indexVal].y = random(height/4, height/4*3);

    if (indexVal == 0) {
      playerA.x = 25; // left side
    } else if (indexVal == 1) {
      playerB.x = width-25; // right side
    }

    println(players[indexVal].name + " is using " + ctrl);
    // ask for sensor data
    myPorts[indexVal].clear();
    myPorts[indexVal].write('k');
  } else {
    // controller is known
    Paddle thisPaddle = players[indexVal];
    String control = thisPaddle.ctrl;

    // base testing controller: potentiometer knob
    if (control.equals("controllerZ")) {
      int value = int(dataIn[0]);
      thisPaddle.y = map(value, 0, 1023, 0, height);
    } // end base controller

    if (control.equals("controllerA")) {
      // up down controls
      // static move
      int up = int(dataIn[0]);
      int dn = int(dataIn[1]);

      thisPaddle.constMove = false;
      thisPaddle.increment = 20;
      thisPaddle.h = height/7;

      if (up == 1 && thisPaddle.upSpeed == 0) {
        // make paddle go up by increment
        thisPaddle.y = thisPaddle.y-(thisPaddle.increment+thisPaddle.adjIncrement);
        thisPaddle.upSpeed = 1; // set value so button cannot be held
      } else if (up == 0 && thisPaddle.upSpeed == 1) {
        thisPaddle.upSpeed = 0; // reset so button can be pressed again
      }

      if (dn == 1 && thisPaddle.dnSpeed == 0) {
        // make paddle go up by increment
        thisPaddle.y = thisPaddle.y+(thisPaddle.increment+thisPaddle.adjIncrement);
        thisPaddle.dnSpeed = 1; // set value so button cannot be held
      } else if (dn == 0 && thisPaddle.dnSpeed == 1) {
        thisPaddle.dnSpeed = 0; // reset so button can be pressed again
      }
    } // end controller A

    if (control.equals("controllerB")) {
      // up down controls
      // const move
      int up = int(dataIn[0]);
      int dn = int(dataIn[1]);
      thisPaddle.constMove = true;
      thisPaddle.increment = 3;
      thisPaddle.h = 85;
      
      if (up == 1 && thisPaddle.upSpeed == 0) {
        // go up
        thisPaddle.upSpeed = 1;
        thisPaddle.dnSpeed = 0;
      }
      if (dn == 1 && thisPaddle.dnSpeed == 0) {
        // go up
        thisPaddle.dnSpeed = 1;
        thisPaddle.upSpeed = 0;
      }
    } // end controller B
    
    if (control.equals("controllerC")){
      // light switch
      // constant movement
      // photo cell
      // bright = up
      // dark = down
      
      int value = int(dataIn[0]);
      thisPaddle.constMove = true;
      thisPaddle.increment = 3;
      thisPaddle.h = height/10;

      // calibrate to get ambient room for 2 seconds
      while (millis() < thisPaddle.time + 1000) {
        thisPaddle.ambientValue = thisPaddle.ambientValue*0.8 + value*0.2;
      }
      
      if (value >= thisPaddle.ambientValue-100) {
        thisPaddle.upSpeed = 1;
        thisPaddle.dnSpeed = 0;
      }  else {
        thisPaddle.dnSpeed = 1;
        thisPaddle.upSpeed = 0;
      }
    } // end controller C
    
    if (control.equals("controllerD")) {
      // flashlight
      // constant movement
      // photo cell
      // bright = down
      // dark = up
      
      int value = int(dataIn[0]);
      thisPaddle.constMove = true;
      thisPaddle.increment = 5;
      thisPaddle.h = height/10;

      // calibrate to get ambient room for 2 seconds
      while (millis() < thisPaddle.time + 1000) {
        thisPaddle.ambientValue = thisPaddle.ambientValue*0.8 + value*0.2;
      }
      
      if (value >= thisPaddle.ambientValue-50) {
        thisPaddle.dnSpeed = 1;
        thisPaddle.upSpeed = 0;
      }  else {
        thisPaddle.upSpeed = 1;
        thisPaddle.dnSpeed = 0;
      }
    } // end of controller D

    if (control.equals("controllerE")) {
      // linear soft pot
      // sequential position
      // static
      // short paddle

      thisPaddle.constMove = false;
      thisPaddle.h = 80;
      thisPaddle.increment = 150;

      int value = int(dataIn[0]);
      
      if (value != 0) { // contact is made, start measuring
        if (thisPaddle.prevSlideValue == 0) {
          // assign start
          println("swipe started: " + value);
          thisPaddle.swipeStart = value;
        } else {
          if (value > thisPaddle.prevSlideValue) {
            thisPaddle.swipeEnd = value;
            thisPaddle.prevSlideValue = value;
          }
        }
      } else if (value == 0) {
        // check if this means finger was lifted
        if (thisPaddle.prevSlideValue != 0) {
          println("swipe ended: " + thisPaddle.prevSlideValue);
          thisPaddle.swipeEnd = thisPaddle.prevSlideValue; // final swipe value
          int swipeLength = thisPaddle.swipeEnd - thisPaddle.swipeStart;
          float stepValue = map(swipeLength, 0, 1023, 20, (thisPaddle.increment+thisPaddle.adjIncrement));
          println(stepValue);
          thisPaddle.y = thisPaddle.y + stepValue;
          if (thisPaddle.y > height) {
            thisPaddle.y = height;
          }
          
          if (thisPaddle.y < 0) {
            thisPaddle.y = 0;
          }
        }
      }

      thisPaddle.prevSlideValue = value;
      myPorts[indexVal].clear();
      myPorts[indexVal].write('k');
    } // end controller E


    if (control.equals("controllerF")) {
      // toggle switch
      // random position
      // static
      // long paddle

      int forward = int(dataIn[0]);
      int backward = int(dataIn[1]);

      thisPaddle.h = height/7;
      thisPaddle.constMove = false;

      if (forward != thisPaddle.prevForwardValue || backward != thisPaddle.prevBackValue) {
        thisPaddle.prevValueOk = true;
      } else {
        thisPaddle.prevValueOk = false;
      }

      if (thisPaddle.prevValueOk) {
        if (forward == 1) {
          if (thisPaddle.positionCounter < thisPaddle.positionsNon.length-1) {
            thisPaddle.positionCounter++;
          } else {
            thisPaddle.positionCounter = 0;
          }
        }

        if (backward == 1) {
          if (thisPaddle.positionCounter > 0) {
            thisPaddle.positionCounter--;
          } else {
            thisPaddle.positionCounter = thisPaddle.positionsNon.length-1;
          }
        }
      }
      thisPaddle.prevForwardValue = forward;
      thisPaddle.prevBackValue = backward;
      thisPaddle.y = thisPaddle.positionsNon[thisPaddle.positionCounter];
    } // end controller F
    
    if (control.equals("controllerG")) {
      // force sensor
      // const move
      // use heavy object
      
      int value = int(dataIn[0]);

      thisPaddle.constMove = true;
      thisPaddle.increment = 8;
      thisPaddle.h = height/10;
      
      if (value >= 10) {
        // go dn
        thisPaddle.dnSpeed = 1;
        thisPaddle.upSpeed = 0;
      } else {
        // go up
        thisPaddle.upSpeed = 1;
        thisPaddle.dnSpeed = 0;
      }
      
    } // end controller G

    myPorts[indexVal].clear();
    myPorts[indexVal].write('k'); // ask for sensor data
  }
}