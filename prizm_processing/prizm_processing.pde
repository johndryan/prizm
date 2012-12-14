/**
 * PRIZM - The Multiplexed Self
 */

import diewald_bardcode.*;
import diewald_bardcode.CONSTANTS.*;
import de.bezier.data.sql.*;

String user     = "multiplex";
String pass     = "prizm";
String database = "multiplex";
String host     = "johnryan.artcenter.edu";

MySQL mysql;
Mux mux;

int numUsersForMux = 5;
int refreshFrequency = 2*1000;
int magStripHeight = 150;
int cornerRadius = 70;
float threshold = 160;
int bgColorAlpha = 100;
int qrcode_size = 250;
int barcodeHeight = 150;
int numMaps = 10;
String qrcode_content = "PRIZM: The Multiplexed Self \n";
int colors[][] = {  {255,221,20},
                    {235,28,35},
                    {240,100,33},
                    {0,160,74},
                    {0,0,0}  };
String url = "http://johnryan.artcenter.edu/prizm/prizm_python_flask/static/captured/face";
int imageSize = 490;
PImage composite = createImage(imageSize, imageSize, RGB);
//int[] whichFaces = {1,2,4,6,7,8,11,12};
PImage[] faces = new PImage[numUsersForMux];
int r, g, b;
color tempPixel;

int timer;
PImage horizontalStrip, verticalStrip, photo, photoMask, temp_map, stamp, barcode;
PImage[] maps = new PImage[numMaps];
PImage[] fingerprints = new PImage[5];
EncodingResult result;
PFont mainFont, labelFont, smallerFont;

void setup() {
  size(1440, 960);
//  frameRate(1);
  timer = 0;

//  String[] fontList = PFont.list();
//  println(fontList);
  mainFont = createFont("KlavikaBold-Bold", 72);
  labelFont = createFont("KlavikaMedCaps-SC", 32);
  smallerFont = createFont("KlavikaRegular-Plain", 48);

  horizontalStrip = loadImage("horizontal_strip.png");
  verticalStrip = loadImage("vertical_strip.png");
  photo = loadImage("test_face.jpg");
  photoMask = loadImage("photo_mask.png");
  for (int i = 0; i < numMaps; i++) {
    maps[i] = loadImage("map" + i + ".jpg", "jpg");
  }
  for (int i = 0; i < 5; i++) {
    fingerprints[i] = loadImage("fingerprint" + i + ".png", "png");
  }
  stamp = loadImage("prism_stamp_white.png");
  
  mux = new Mux(0," ");
  
//  mysql = new MySQL( this, host, database, user, pass );
  
  multiplexMe();
} 

void draw() {
  timer++;
  if( millis() - timer >= refreshFrequency){
    multiplexMe();
    timer = millis();
  }
}

void multiplexMe() {
       
    mysql = new MySQL( this, host, database, user, pass );
    mux.update();
    
    background(255);
    
    int layout = (int)random(4);
    
    println("drawBackground");
    drawBackground();
    
    println("drawFingerprint");
    drawFingerprint(layout);
    
    createPhoto();
    drawPhoto(layout);
    
    drawQRBarcode(layout);
    
    drawText(layout);
    
    drawStrip(layout);
    
    println("drawCorners");
    drawCorners();
    timer = millis();
}

void drawBackground() {
  randomColor("fill");
  rect(0,0,width,height);
  
  println("randomNums");
  int random1 = int(random(numMaps));
  int random2 = int(random(numMaps));
  int random3 = int(random(numMaps));
  while (random1 == random2) random2 = int(random(numMaps));
  while (random3 == random1 || random3 == random2) random3 = int(random(numMaps));

  println("Thresholding");  
  doThreshold(maps[random1]);
  image(temp_map,0,0,width,height);
  doThreshold(maps[random2]);
  blend(temp_map, 0, 0, maps[random2].width, maps[random2].height, 0, 0, width, height, MULTIPLY);
  doThreshold(maps[random3]);
  blend(temp_map, 0, 0, maps[random3].width, maps[random3].height, 0, 0, width, height, MULTIPLY);
  
  println("End");
  
  noStroke();
  fill(255, bgColorAlpha);
  rect(0,0,width,height);
}

void drawStrip(int layout) {
  fill(0);
  noStroke();
  switch(layout) {
    case 0: 
      image(horizontalStrip, 0, 65);
      break;
    case 1: 
      image(horizontalStrip, 0, height-65-258);
      break;
    case 2: 
      image(verticalStrip, 100, 0);
      break;
    case 3: 
      image(verticalStrip, width-100-258, 0);
      break;
  }
  
}

void createPhoto() {
  composite.loadPixels();

  for (int i = 0; i < numUsersForMux; i++) {
    faces[i] = loadImage(url + mux.whichFaces[i] + ".png", "png");
    // CREATE FALLBACK?
    faces[i].resize(imageSize,imageSize);
    faces[i].loadPixels();
  }

  for (int i = 0; i < faces[0].pixels.length; i++) {
    r = 0;
    g = 0;
    b = 0;
    for (int j = 0; j < numUsersForMux; j++) {
      int pixelColor = faces[j].pixels[i];
      r += (pixelColor >> 16) & 0xff;
      g += (pixelColor >> 8) & 0xff;
      b += pixelColor & 0xff;
    }
    tempPixel = color(int(r/numUsersForMux),int(g/numUsersForMux),int(b/numUsersForMux));
    composite.pixels[i] = tempPixel;
  }

  composite.updatePixels();
}

void drawPhoto(int layout) {
  pushMatrix();
  switch(layout) {
    case 0: 
      translate(90, height-90-490);
      break;
    case 1: 
      translate(90, 90);
      break;
    case 2: 
      translate(width-90-368, 90);
      break;
    case 3: 
      translate(90, 90);
      break;
  }
  composite.mask(photoMask);
  image(composite, -61, 0);
  strokeWeight(10);
  randomColor("stroke");
  beginShape();
    vertex(0, 30);
    vertex(30, 0);
    vertex(338, 0);
    vertex(368, 30);
    vertex(368, 460);
    vertex(338, 490);
    vertex(30, 490);
    vertex(0, 460);
  endShape(CLOSE);
  int whichSide = (int)random(2);
  whichSide = (whichSide == 0) ? -50 : 278;
  int whichColor = (int)random(colors.length);
  tint(colors[whichColor][0],colors[whichColor][1],colors[whichColor][2],180);
  image(stamp, whichSide, (int)random(-50,440));
  noTint();
  popMatrix();
}

void drawCorners() {
  fill(0);
  noStroke();
  triangle(0,0,cornerRadius,0,0,cornerRadius);
  triangle(0,height,0,height-cornerRadius,cornerRadius,height);
  triangle(width,0,width-cornerRadius,0,width,cornerRadius);
  triangle(width,height,width-cornerRadius,height,width,height-cornerRadius);
}

void randomColor(String strokeOrColor) {
  int whichColor = (int)random(colors.length);
  if (strokeOrColor == "stroke") {
    noFill();
    stroke(colors[whichColor][0],colors[whichColor][1],colors[whichColor][2]);
  } else {
    noStroke();
    fill(colors[whichColor][0],colors[whichColor][1],colors[whichColor][2]);
  }
}

void doThreshold(PImage myImage) {
  int whichColor = (int)random(colors.length);
  temp_map = createImage(myImage.width, myImage.height, RGB);
  temp_map.loadPixels();
  myImage.loadPixels();
  
  for (int x = 0; x < myImage.width; x++) {
    for (int y = 0; y < myImage.height; y++ ) {
      int loc = x + y*myImage.width;
      // Test the brightness against the threshold
      if (brightness(myImage.pixels[loc]) > threshold) {
        temp_map.pixels[loc]  = color(255);  // White
      }  else {
        temp_map.pixels[loc]  = color(colors[whichColor][0],colors[whichColor][1],colors[whichColor][2]);    // Black
      }
    }
  }
  temp_map.updatePixels();  
}

void drawQRBarcode(int layout) {
  int whichColor = (int)random(colors.length);
  int barcodeWidth = (int)(width/random(1,3));
  
  int qrx, qry, barcodex, barcodey;
   switch(layout) {
    case 0:
      qrx = (int)random(380, width-80-qrcode_size);
      qry = (int)random(450, 90-qrcode_size);
      barcodex = (width - barcodeWidth)/2;
      barcodey = 0;
      break;
    case 1:
      qrx = (int)random(380, width-80-qrcode_size);
      qry = (int)random(90, height-450-qrcode_size);
      barcodex = (width - barcodeWidth)/2;
      barcodey = height-barcodeHeight;
      break;
    default: 
      qrx = (int)random(420, width-420-qrcode_size);
      qry = (int)random(90, height-90-qrcode_size);
      barcodex = (height - barcodeWidth)/2;
      barcodey = -barcodeHeight;
      if(layout==3) barcodey = -width;
      break;
  }
  
  result = Barcode.encode(qrcode_content+mux.url, ENCODE.QR_CODE, qrcode_size, qrcode_size, CHARACTER_SET.DEFAULT, ERROR_CORRECTION.DEFAULT);
  if( result.encodingFailed() ){
    println( result.getEncodingException() );
  } else {
    result.setBgColor(255, 255, 255, 255);
    result.setCodeColor(colors[whichColor][0],colors[whichColor][1],colors[whichColor][2], 255);
  
    barcode = result.asImage(this);
    if ( barcode != null)
      image(barcode, qrx, qry);
  }
  
  whichColor = (int)random(4);
  
  pushMatrix();
  if(layout==2 || layout==3) rotate(HALF_PI);
  result = Barcode.encode(mux.url, ENCODE.CODE_128, barcodeWidth, barcodeHeight, CHARACTER_SET.DEFAULT, ERROR_CORRECTION.DEFAULT);
  if( result.encodingFailed() ){
    println( result.getEncodingException() );
  } else {
    result.setBgColor(255, 255, 255, 0);
    result.setCodeColor(colors[whichColor][0],colors[whichColor][1],colors[whichColor][2], 255);
  
    barcode = result.asImage(this);
    if (barcode != null)
      image(barcode, barcodex, barcodey);
  }
  popMatrix();
}

void drawFingerprint(int layout) {
  int x = 0;
  int y = 0;
  switch(layout) {
    case 0: 
      x = int(random(450,width-50-300));
      y = int(random(50,height-50-300));
      break;
    case 1: 
      x = int(random(450,width-50-300));
      y = int(random(50,height-50-300));
      break;
    case 2:
      x = int(random(50,width-50-300-450));
      y = int(random(50,height-50-300));
      break;
    case 3:
      x = int(random(450,width-50-300));
      y = int(random(50,height-50-300));
      break;
  }
  image(fingerprints[int(random(5))],x,y);
}

void drawText(int layout) {
  pushMatrix();
  switch(layout) {
    case 0: 
      translate(520, 400);
      break;
    case 1: 
      translate(520, 200);
      break;
    case 2: 
      translate(400, 400);
      break;
    case 3: 
      translate(300, 90);
      break;
  }
  
  randomColor("fill");
  
  textAlign(RIGHT, BOTTOM);
  textFont(labelFont);
  text("Mux #:", 100, 50);
  text("Name:", 100, 130);
  text("D.O.B.:", 100, 210);
  
  textAlign(LEFT, BOTTOM);
  textFont(mainFont);
  text(nf(mux.id,8), 120, 70);
  text(mux.name, 120, 150);
  textFont(smallerFont);
  text(mux.dob, 120, 230);
  
  popMatrix();
}
