void sharedController(int indexVal, String[] inputArr) {
  String[] dataIn = inputArr;
  
  if (dataIn[0].equals("plugged")) {
    println("shared controller plugged in");
    //ask for name
    myPorts[indexVal].clear();
    myPorts[indexVal].write('a'); // ask for name
    
  } else if (dataIn[0].equals("hello")) {
    println("shared controller identified");
    // ask for sensor data
    myPorts[indexVal].clear();
    myPorts[indexVal].write('k');
    
  } else {
    int ballSpeed = int(dataIn[0]);
    int buttonValue = int(dataIn[1]);
    
    float mapSpeed = map(ballSpeed,0,1023,0.5,5);
    ball.multiplier = mapSpeed;
    
    if (controllerScreen && buttonValue == 1) {
      controllerScreen = false;
      gameScreen = true;
    }
    
    if (deadScreen && buttonValue == 1) {
      deadScreen = false;
      gameScreen = true;
      ball.reset();
    }

    myPorts[indexVal].clear();
    myPorts[indexVal].write('k');
  }
}