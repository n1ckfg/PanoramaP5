// https://forum.processing.org/two/discussion/21046/panorama-using-a-webcam

import boofcv.processing.*;
import boofcv.struct.image.*;
import boofcv.struct.feature.*;
import georegression.struct.point.*;
import java.util.*;
 
PImage prevFrame;
PImage currentFrame;
PImage finalImg;
PGraphics finalGfx;
boolean firstRun = true;
int w = 320;
int h = 240;
int cam = 95; // 16;
int alpha = 10;
boolean debug = true;
float maxDist = 50;

List<Point2D_F64> locations0, locations1;      // feature locations
List<AssociatedIndex> matches;      // which features are matched together
 
void setup() {
  size(960, 720, P2D);
  
  setupWebcam(w, h, cam);
  
  prevFrame = createImage(video.width, video.height, RGB);
  currentFrame = createImage(video.width, video.height, RGB);
  finalImg = createImage(video.width, video.height, RGB);

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
  
  float longestDist = 0;
  finalGfx.beginDraw();
  for (AssociatedIndex i : matches) {       
    Point2D_F64 p0 = locations0.get(i.src); 
    Point2D_F64 p1 = locations1.get(i.dst); 
    PVector pp0 = new PVector((float) p0.x, (float) p0.y);
    PVector pp1 = new PVector((float) p1.x, (float) p1.y);
    float dist = PVector.dist(pp0, pp1);
    if (dist > longestDist) longestDist = dist;
    
    if (dist < maxDist) {
      finalImg.copy(currentFrame, int(pp1.x), 0, int(pp1.x), video.height, int(pp1.x), 0, int(pp1.x), video.height);
      finalGfx.tint(255, alpha);
      finalGfx.image(finalImg, 0, 0);
      if (debug) {
        finalGfx.noTint();
        finalGfx.strokeWeight(2);
        finalGfx.stroke(0,255,0);
        finalGfx.line(pp0.x, pp0.y, pp1.x, pp1.y);

      }
    } else {
      if (debug) {
        finalGfx.noTint();
        finalGfx.strokeWeight(2);
        finalGfx.stroke(255,0,0);
        finalGfx.line(pp0.x, pp0.y, pp1.x, pp1.y);
      }    
    }
  }
  finalGfx.endDraw();
  println(longestDist);
}
