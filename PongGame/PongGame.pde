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
  size(1200, 700);
  rectMode(CENTER);
  textAlign(CENTER);

  background(0);

  // create a new server
  serv = new Server(this, port);
  if (serv.active()) {
    serverIP = Server.ip();
    println("server is active");
    println("server ip: " + serverIP);
    // 172.16.245.191 (NYU)
    // 169.254.130.186 (macbook as network????)
    // 172, 20, 10, 3 (iPhone hotspot)
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
    }
  }

  if (activeClients.size() == players.length) {
    // let's play!
    ball.display();
    ball.move();
    displayPoints();
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
        // emptry player found!
        thisPlayer = players[i];

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
    thisPlayer.ctrl = message.substring(5);

    switch (thisPlayer.ctrl) {
    case "controllerA":
      thisPlayer.constMove = false;
      thisPlayer.increment = 30;
      break;

    case "controllerB":
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
        println("adjust player " + i);
      }
    }

    switch (message) {
    case "u":
      if (thisPlayer.constMove == false) {
        thisPlayer.y = thisPlayer.y - thisPlayer.increment;
      } else {
        thisPlayer.upSpeed = 1;
        thisPlayer.dnSpeed = 0;
      }
      break;

    case "d":
      thisPlayer.y = thisPlayer.y + thisPlayer.increment;
      if (thisPlayer.constMove == false) {
        thisPlayer.y = thisPlayer.y + thisPlayer.increment;
      } else {
        thisPlayer.upSpeed = 0;
        thisPlayer.dnSpeed = 1;
      }
      break;
    }
  }
}

void removeClient(Client thisClient) {
  String clientID = thisClient.ip();

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

  for (int i = 0; i < activeClients.size(); i++) {
    if (activeClients.get(i).equals(clientID)) {
      // remove client from list
      activeClients.remove(i);
    }
  }

  // close connection with client
  serv.disconnect(thisClient);
}