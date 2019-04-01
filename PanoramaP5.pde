// https://forum.processing.org/two/discussion/21046/panorama-using-a-webcam

import boofcv.processing.*;
import boofcv.struct.image.*;
import boofcv.struct.feature.*;
import georegression.struct.point.*;
import java.util.*;
 
PImage prevFrame;
PImage currentFrame;
PImage bufferImg;
PGraphics finalGfx;
boolean firstRun = true;
int w = 320;
int h = 240;
String cam = "HD Pro Webcam C920";
int alpha = 63;
boolean debug = true;
float strokeWeightNum = 4;
float maxDist = 50;

List<Point2D_F64> locations0, locations1;      // feature locations
List<AssociatedIndex> matches;      // which features are matched together
 
void setup() {
  size(960, 720, P2D);
  
  setupWebcam(w, h, cam, 30);
 
  prevFrame = createImage(video.width, video.height, RGB);
  prevFrame.loadPixels();
  currentFrame = createImage(video.width, video.height, RGB);
  currentFrame.loadPixels();
  bufferImg = createImage(video.width, video.height, RGB);

  finalGfx = createGraphics(video.width, video.height, P2D);
  finalGfx.beginDraw();
  finalGfx.background(0);
  finalGfx.endDraw();
}
 
void draw() {
  if (frameReceived) {
    detect();
    frameReceived = false;
  }
 
  image(finalGfx, 0, 0, width, height);
  
  surface.setTitle("" + frameRate);
}
 
void detect() {
  if (firstRun) {
    prevFrame.copy(videoFrame, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
    firstRun = false;
  } else {
    prevFrame.copy(currentFrame, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  }
  
  currentFrame.copy(videoFrame, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
  
  SimpleDetectDescribePoint ddp = Boof.detectSurf(true, ImageDataType.F32);  //use SURF
  SimpleAssociateDescription assoc = Boof.associateGreedy(ddp, true);  // continuous search
 
  // Find the features
  ddp.process(prevFrame);
  locations0 = ddp.getLocations();
  List<TupleDesc> descs0 = ddp.getDescriptions();
 
  ddp.process(currentFrame);
  locations1 = ddp.getLocations();
  List<TupleDesc> descs1 = ddp.getDescriptions();
 
  // associate the points
  assoc.associate(descs0, descs1);
  matches = assoc.getMatches();
  
  finalGfx.beginDraw();
  finalGfx.beginShape(LINES);
  for (AssociatedIndex i : matches) {       
    Point2D_F64 p0 = locations0.get(i.src); 
    Point2D_F64 p1 = locations1.get(i.dst); 
    PVector pp0 = new PVector((float) p0.x, (float) p0.y);
    PVector pp1 = new PVector((float) p1.x, (float) p1.y);
    float dist = PVector.dist(pp0, pp1);
    
    float diffX = abs(pp1.x - pp0.x);
    int x1 = int(pp1.x - diffX);
    int x2 = int(pp1.x + diffX);
    
    if (dist < maxDist) {
      bufferImg.copy(currentFrame, x1, 0, x1, video.height, x2, 0, x2, video.height);

      finalGfx.strokeWeight(1);
      int loc = int(pp0.x) + int(pp0.y) * currentFrame.width;
      finalGfx.stroke(color(prevFrame.pixels[loc], 0));// alpha));
      finalGfx.vertex(pp0.x, pp0.y);

      finalGfx.strokeWeight(strokeWeightNum);
      loc = int(pp1.x) + int(pp1.y) * currentFrame.width;
      finalGfx.stroke(color(currentFrame.pixels[loc], alpha));
      finalGfx.vertex(pp1.x, pp1.y);
    }
  }
 
  finalGfx.endShape();
  
  finalGfx.tint(255,alpha/2);
  finalGfx.image(bufferImg, -6, 0);
  finalGfx.noTint();
  finalGfx.endDraw();
}
