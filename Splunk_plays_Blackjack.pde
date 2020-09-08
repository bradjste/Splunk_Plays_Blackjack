import hypermedia.net.*;
import http.requests.*;
import java.time.Instant;
import java.util.Map;
import java.util.Iterator;

//http info
String httpURL = "";
String httpPostKey = "";
String token = "";

//udp info
String ip = "";  // the remote IP address
int port = 3000;

//log interval in ms
float sendInterval = 5000;

int sendIndiCount = 0;
boolean sendIndiFlag = false;
color splunkCol1;
color splunkCol2;
PFont splunkSBR;
PFont splunkSBI;
int flairDots = 100;
PImage[] dealerCards; 
PImage[] splunkCards;
boolean options = false;
boolean isLog = true;
PImage header; 
PImage dealerText;
int lastSendTime = millis();
PImage cardFrame;
PImage splunkHandText;
int dealerUpCard=11;
float sumHSpacing = 0;
int splunkSum = 0;


boolean cursorOnSplunk = false;
ArrayList<Integer> splunkHand;
float phase = 0;
UDP udp;  

void setup() {
  size(680,950);
  surface.setResizable(true);
  splunkSBI = createFont("Stone Sans Italic.ttf",50);
  splunkSBR = createFont("Stone Sans Semi Bold Regular.ttf",100);
  udp = new UDP( this,5000);
  textFont(splunkSBR);
  splunkCol1= color(#e9168c);
  splunkCol2= color(#f38f39);
  header = loadImage("assets/header.png");
  splunkHandText = loadImage("assets/splunkHand.png");
  splunkHandText.resize(int(width*0.75),0);
  cardFrame = loadImage("assets/cardFrame.png");
  cardFrame.resize(int(width*0.18),0);
  dealerText = loadImage("assets/dealUpCard.png");
  dealerText.resize(int(width*0.75),0);
  dealerCards = loadCards("Dealer");
  splunkCards = loadCards("Splunk");
  smooth(4);
  splunkHand = new ArrayList<Integer>();
  splunkHand.add(11);
  colorMode(HSB,360,100,100,100);
  background(0);
  drawInitialState();
}

void draw() {
  background(0);
  drawInitialState();
  //if (canLog()) {
  //  //broadcastUDP();
  //  broadcastHTTP();
  //}
  if (options) {
    displayOptions();
  }
  if (sendIndiFlag) {
    displayIndi((sendIndiCount-1)%10+1);
    if (sendIndiCount < 10) {
      sendIndiCount++;
    } else {
      sendIndiCount = 0;
      sendIndiFlag = false;
    }
  }
}

void displayIndi(int whichAngle) {
  fill(110,100,100);

  text(">",40+whichAngle*width*0.08,height*0.97);
  //noStroke();
  //rect(0,height*0.95,width,height);
}

void broadcastHTTP() {
  Map httpPostValues = makeLogMessage();
  System.out.println(httpPostValues);
  //JSONObject jsonPostValue;
  PostRequest post = new PostRequest(httpURL,"UTF-8");
  post.addHeader("Authorization", "Splunk " + token);
  Iterator it = httpPostValues.entrySet().iterator();
  while (it.hasNext()) {
    Map.Entry pair = (Map.Entry)it.next();
    post.addData(pair.getKey().toString(),pair.getValue().toString());
  }
  post.send();
  System.out.println("Reponse Content:" + post.getContent() + "\n");
}

boolean canLog() {
  if (millis() > lastSendTime + sendInterval) {
    lastSendTime = millis();
    return true;
  } else {
    return false; 
  }
}

void drawInitialState(){
    drawTextInfo();
    drawUpCard();
    drawSplunkCardFrames();
    drawSplunkHand();
    drawCursor();
}

void flair() {
  noStroke();
  for (int x = 0; x < flairDots; x++) {
    if (x < flairDots/2) {
      fill(326,90.6*(1-(x/(flairDots*0.5))),91.4,40);
    } else {
      fill(28,76.5*(((x-flairDots*0.5)/(flairDots*0.5))),95.3,40);
    }
    ellipse(width*(x/(flairDots/1.0)), height*0.85+height*0.06*sin((width-x)/(flairDots/1.0)*TWO_PI*10+phase),10,10);
  }
  phase+=0.05;
  if (phase >= TWO_PI) {
    phase = 0;
  }
}

void displayOptions() {
  fill(0,0,0,80);
  stroke(360);
  strokeWeight(3);
  rect(-2,height*0.7-10,width+2,height-10);
  noStroke();
  flair();
  drawInput();
}

void drawInput() {
  fill(360);
  textSize(30);
  if (isLog) {
     text("log: ",800,700);
  } else {
     text("ip: ",800,700);
  }
}

void drawSplunkCardFrames() {
  for (int i = 0; i < 4; i++) {
    image(cardFrame, 80 + i*width/5.0, height*0.58);
  }
}

void drawSplunkHand() {
  if (splunkHand.size() > 4) {
    sumHSpacing = height*0.08;
  } else {
    sumHSpacing = 0;
  }
  splunkSum = 0;
  for (int i = 0; i < splunkHand.size(); i++) {
      int cardValue = splunkHand.get(i);
      if (i <= 3) {
        image(splunkCards[cardValue], 80 + i*width/5.0, height*0.58);
      } else {
        image(splunkCards[cardValue], 100 + (i-4)*width/5.0, height*0.66);
      }
      if (cardValue == 11) cardValue = -1;
      splunkSum += cardValue + 1;
  }
  if (splunkSum > 21){
    changeAceDown();
  } else if (splunkSum < 11) {
    changeAceUp();
  }
  drawSum();
}

void drawSum(){
  fill(360);
  textSize(60);
  text("hand sum: ",80, height*0.82 + sumHSpacing);
  fill(200,100*(splunkSum/21.0),100);
  if (splunkSum == 21) {
     fill(120,100,100);   
  } else if (splunkSum > 21) {
    fill(0,100,100);
  }
  text("                   "+splunkSum,70,height*0.82+ sumHSpacing);
}

void changeAceDown() {
    boolean aceFound = false;
    for (int i = 0; i < splunkHand.size(); i++) {
      if (splunkHand.get(i) == 10 && !aceFound) {
        aceFound = true;
        splunkSum -= 10;
        drawSplunkCardFrames();
        splunkHand.set(i,0);
        drawSplunkHand();
       }
    }
}

void changeAceUp() {
    boolean aceFound = false;
    for (int i = 0; i < splunkHand.size(); i++) {
      if (splunkHand.get(i) == 0 && !aceFound) {
        aceFound = true;
        splunkSum += 10;
        drawSplunkCardFrames();
        splunkHand.set(i,10);
        drawSplunkHand();
       }
    }
}

void drawTextInfo() {
  image(header,0,20,width,header.height*(width*1.0/header.width));
  image(splunkHandText,40,height*0.45);
  image(dealerText, 40,height*0.15);
  drawUpCard();
}

PImage[] loadCards(String name) {
  PImage[] cardArray = new PImage[12];
  for (int i = 1; i < 13; i++) {
    cardArray[i-1] = loadImage("assets/"+name+"/card"+i+name+".png");
    cardArray[i-1].resize(int(width*0.18),0);
  }
  return cardArray;
}

void drawUpCard() {
  image(dealerCards[dealerUpCard],80,height*0.27);
}

void drawCursor() {
  if(cursorOnSplunk) {
    fill(#e9168c);
    ellipse(50,height*0.58+dealerCards[0].height*0.5,20,20);
  } else {
    fill(#f38f39);
    ellipse(50,height*0.27+dealerCards[0].height*0.5,20,20);
  }
}
void clear() {
  background(0);
  cursorOnSplunk = false;
  splunkHand.clear();
  splunkHand.add(11);
  dealerUpCard = 11;
  drawUpCard();
  drawInitialState();
}

void broadcastUDP() {
    String message  = makeLogMessage().toString();  // the message to send
    // send the message
    udp.send( message, ip, port );
}

Map makeLogMessage() {
  int dealerUpCardSend = 0;
  if (dealerUpCard != 11) {
    dealerUpCardSend = dealerUpCard+1;
  }
  Map sendMap = new HashMap();
  sendMap.put("time",System.currentTimeMillis()/1000);
  sendMap.put("dealerUp",dealerUpCardSend);
  String dHardSoft = "hard";
  if (dealerUpCard == 10) {
    dHardSoft = "soft";
  }
  sendMap.put("dealerHardSoft",dHardSoft);
  int myFirst = 0;
  if (splunkHand.size() > 0) {
    if (splunkHand.get(0) != 11) {
      myFirst = splunkHand.get(0) + 1;
    }
  }
  int mySecond = 0;
  if (splunkHand.size() > 1) {
    if (splunkHand.get(0) != 11) {
      mySecond = splunkHand.get(1) + 1;
    }
  }
  sendMap.put("myFirst",myFirst);
  sendMap.put("mySecond",mySecond);
  sendMap.put("mySum",splunkSum);
  String sHardSoft = "hard";
  for (int i = 0; i < splunkHand.size(); i++) {
    if (splunkHand.get(i) == 10) {
      sHardSoft = "soft";
    }
  }
  sendMap.put("myHardSoft",sHardSoft);
  return sendMap;
}

void keyPressed() {
    if (key == 48) {
      if(cursorOnSplunk) {
        splunkHand.set(splunkHand.size()-1,9);      
        drawSplunkHand();
      } else {
        dealerUpCard = 9;
        drawUpCard();
      }
    } else if (key == 49) {
      if(cursorOnSplunk) {
        splunkHand.set(splunkHand.size()-1,10);     
        drawSplunkHand();
      } else {
        dealerUpCard = 10;
        drawUpCard();
      }
    }
    else if (key >= 50 && key < 58){
      if (cursorOnSplunk) {
        splunkHand.set(splunkHand.size()-1,key-49);
        drawSplunkHand();
      } else {
        dealerUpCard=key-49;
        drawUpCard();
      }
    } else if (key == ENTER) {
      if  (cursorOnSplunk && splunkHand.get(splunkHand.size()-1) != 11) {
        splunkHand.add(11);
        drawSplunkHand();
      } else {
        cursorOnSplunk = true;
        drawCursor();
      }
    } else if (key == '.'){
      cursorOnSplunk = !cursorOnSplunk;
      drawCursor();
    } else if (key == '+') {
      clear();
    } else if (key == '-' && splunkHand.size() > 1) {
      splunkHand.remove(splunkHand.size()-1);
      drawSplunkCardFrames();
      drawSplunkHand();
    } else if (key == '/') {
      sendIndiCount = 0;
      sendIndiFlag = true;
      broadcastHTTP();
    }
}
