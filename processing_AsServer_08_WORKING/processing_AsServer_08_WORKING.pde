import processing.net.*;


// variables for clients and server
Server serv;                   // server object
String serverIP;
int port = 12345;
StringList activeClients;      // keep track of clients

// Array to track players
Paddle[] players = new Paddle[2];
// NOTE: use index value in array to determine Player A or B

// Graphic Display Elements
Ball ball;
int offsetDist = 40;
boolean developMode = true;

void setup() { 
  size(1000, 600);
  rectMode(CENTER);
  textAlign(CENTER);

  background(0);

  // create a new server
  serv = new Server(this, port);
  if (serv.active()) {
    serverIP = Server.ip();
    println("server is active");
    println("server ip: " + serverIP);
    // 172.16.240.183 (NYU)
  }

  // setup clients
  activeClients = new StringList();

  // setup ball
  ball = new Ball();

  // setup players
  for (int i = 0; i < players.length; i++) {
    players[i] = new Paddle();
    players[i].index = i;
    if (i == 0) {
      players[i].x = offsetDist;
      // left side
    } else {
      players[i].x = width-offsetDist;
    }
  }
} 


void draw() {
  listenToClients();
  checkFullList();

  background(20, 50, 200);

  for (int i = 0; i < players.length; i++) {
    if (players[i].clientID != null) {
      // show the paddle
      players[i].display();
      // move the paddle (if applicable)
      players[i].move();
      if (developMode) {
        players[i].develop();
      }
    } else {
      fill(255);
      noStroke();
      textAlign(CENTER);
      textSize(30);
      text("turn on a controller", width/2, height/2);
      players[0].points = 0;
      players[1].points = 0;
      players[0].constMove = false;
      players[1].constMove = false;
    }
  }

  if (activeClients.size() == players.length && players[0].points < 11 && players[1].points < 11) {
    // let's play!
    ball.display();
    ball.move();
    displayPoints();
  }
  
  if (players[0].points == 11 || players[1].points== 11) {
    fill(255);
    noStroke();
    textSize(24);
    textAlign(CENTER);
    if (players[0].points == 11) {
      text("player A wins!", width/2, height/2);
      
    } else {
      text("player B wins!", width/2, height/2);
    }
  }
}

void displayPoints() {
  // display points 
  fill(255);
  noStroke();
  textSize(24);
  textAlign(RIGHT);
  text(players[0].points, width/4, height-20);
  textAlign(LEFT);
  text(players[1].points, width-width/4, height-20);
}


void checkFullList() {
}

// ServerEvent message is generated when a NEW client connects 
// to an existing server.
void serverEvent(Server theServer, Client theClient) {
}

void listenToClients() {
  // get message from client
  Client thisClient = serv.available();

  // check that client isnt null
  if (thisClient != null) {
    String message = thisClient.readString();
    // check that it said something
    if (message != null) {
      if (message.equals("remove")) {
        println("received message to remove");
        removeClient(thisClient);
      } else if (message.indexOf("hello") != -1) {
        checkClient(thisClient, message);
      } else {
        adjustPlayer(thisClient, message);
      }
    }
  }
}

void checkClient(Client thisClient, String message) {
  String clientID = thisClient.ip();

  Paddle thisPlayer = new Paddle();

  // check if this is an existing client or new
  if (activeClients.hasValue(clientID) == true) {
    // use message as behaviour
    println("uh oh! client exists?");
  } else {
    // check if any paddle has an empty client
    for (int i = 0; i < players.length; i++) {
      if (players[i].clientID == null) {
        // empty player found!
        thisPlayer = players[i];
        println("empty player found");

        // add client to list
        activeClients.append(clientID);
        break;
      }
    }
    // assign properties of controller to player
    // assign client to first empty player
    thisPlayer.clientID = clientID;
    println("added " + clientID + ", " + thisPlayer.ctrl);
    // name - substring will always start at index 5
    thisPlayer.ctrl = message.substring(5, 16); // make sure only the name is captured


    // initial values
    switch (thisPlayer.ctrl) {
    case "controllerA":
      // two switches (direction), pot (speed)
      thisPlayer.constMove = true;
      thisPlayer.increment = 3;
      break;

    case "controllerB":
      // two buttons (increment)
      thisPlayer.constMove = false;
      thisPlayer.increment = height/35;
      thisPlayer.upSpeed = 0;
      thisPlayer.dnSpeed = 0;
      break;

    case "controllerC":
      // two buttons (direction)
      thisPlayer.constMove = true;
      thisPlayer.increment = 3;
      break;

    case "controllerD":
      // lots of buttons (position)
      thisPlayer.constMove = false;
      thisPlayer.increment = 0;
      break;

    case "controllerE":
      // slider potentiometer mapped to position on screen
      thisPlayer.constMove = false;
      break;

    case "controllerF":
      // round potentiometer controls direction and speed
      thisPlayer.constMove = true;
      thisPlayer.increment = 3;
      break;
    }
  }
}




void adjustPlayer(Client thisClient, String message) {
  // which player?
  Paddle thisPlayer = new Paddle();
  String clientID = thisClient.ip();

  if (activeClients.size() == players.length) {

    // determine with player client is associated with
    for (int i = 0; i < players.length; i++) {
      if (players[i].clientID.equals(clientID)) {
        // player identified!
        thisPlayer = players[i];
      }
    }

    if (thisPlayer.ctrl.equals("controllerA")) {
      // two switches (direction), pot (speed)
      // adjust speed increment
      if (message.substring(0, 1).equals("s")) {
        thisPlayer.increment = int(message.substring(1));
      }

      // change movement for each direction
      switch (message) {
      case "u":
        // constantly moving
        thisPlayer.upSpeed = 1;
        thisPlayer.dnSpeed = 0;
        break;

      case "d":
        // constantly moving
        thisPlayer.upSpeed = 0;
        thisPlayer.dnSpeed = 1;
        break;

      case "reset":
        // stop constantly moving
        thisPlayer.upSpeed = 0;
        thisPlayer.dnSpeed = 0;
        break;
      }
    } else if (thisPlayer.ctrl.equals("controllerB")) {
      // change movement for each direction
      println("received");
      switch (message) {
      case "u":
        thisPlayer.y = thisPlayer.y - thisPlayer.increment;
        break;

      case "d":
        println(message);
        thisPlayer.y = thisPlayer.y + thisPlayer.increment;
        break;
      }
    } else if (thisPlayer.ctrl.equals("controllerC")) {
      // two buttons for controlling direction, no speed
      
      // change movement for each direction
      switch (message) {
      case "u":
        // constantly moving
        thisPlayer.upSpeed = 1;
        thisPlayer.dnSpeed = 0;
        break;

      case "d":
        // constantly moving
        thisPlayer.upSpeed = 0;
        thisPlayer.dnSpeed = 1;
        break;
      }
    } else if (thisPlayer.ctrl.equals("controllerD")) {
      // many buttons
      int displayIncrement = height/9;
      int receivedPosition = int(message.substring(1));
      println("d move");
      
      thisPlayer.y = (receivedPosition-1)*displayIncrement + displayIncrement/2;
      thisPlayer.upSpeed = 0;
      thisPlayer.dnSpeed = 0;
      
    } else if (thisPlayer.ctrl.equals("controllerE")) {
      // slider potentiometer mapped to position on screen
      // map message
      if (int(message) < 868) {
        thisPlayer.y = map(int(message), 0, 868, height, 0);
      } else {
        println(message.substring(0, 3));
        thisPlayer.y = map(int(message.substring(0, 3)), 0, 868, 0, height);
      }
    } else if (thisPlayer.ctrl.equals("controllerF")) {
      // round potentiometer controls direction and speed
      // message starts with a letter and ends with speed number

      // set direction
      switch (message.substring(0, 1)) {
      case "u":
        thisPlayer.upSpeed = 1;
        thisPlayer.dnSpeed = 0;
        break;

      case "d":
        thisPlayer.upSpeed = 0;
        thisPlayer.dnSpeed = 1;
        break;

      case "r":
        thisPlayer.upSpeed = 0;
        thisPlayer.upSpeed = 0;
        break;
      }

      // set speed 
      thisPlayer.increment = int(message.substring(1));
    }
  }
}

void removeClient(Client thisClient) {

  String clientID = thisClient.ip();

  println(clientID + " should be removed");

  // close connection with client
  serv.disconnect(thisClient);

  for (int i = 0; i < activeClients.size(); i++) {
    if (activeClients.get(i).equals(clientID)) {
      // remove client from list
      activeClients.remove(i);
    }
  }

  // determine with player client is associated with
  for (int j = 0; j < players.length; j++) {
    if (players[j].clientID != null) {
      if (players[j].clientID.equals(clientID)) {
        // remove client from player
        players[j].clientID = null;
        println("removed " + clientID + " from player " + j);
      }
    }
  }
}

void keyPressed() {
  
  // RESTART
  if (key == 'R' || key == 'r') {
    players[0].points = 0;
    players[1].points = 0;
    
  }
  
  // DEVELOPMENT MODE
  if (key == 'd' || key == 'D') {
    developMode = !developMode;
  }
  
  // DECREASE BALL SPEED
  if (key == 'b' || key == 'B') {
    ball.multiplier++;
  } 
  
  if (key == 'v' || key == 'v') {
    ball.multiplier--;
  } 
  
  // PAUSE
  if (key == 'p' || key == 'P') {
    if (ball.multiplier != 0) {
      ball.multiplier = 0;
    } else {
      ball.multiplier = 3;
    }
  }

}