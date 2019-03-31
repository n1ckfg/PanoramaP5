// https://forum.processing.org/two/discussion/21046/panorama-using-a-webcam

import boofcv.processing.*;
import boofcv.struct.image.*;
import boofcv.struct.feature.*;
import georegression.struct.point.*;
import java.util.*;
import processing.video.*;
 
Capture video;
 
PImage prevFrame;
PImage currentFrame;
 
boolean firstRun = true;
boolean armDetect = false;

List<Point2D_F64> locations0, locations1;      // feature locations
List<AssociatedIndex> matches;      // which features are matched together
 
void setup() {
  size(640, 480, P2D);
  
  video = new Capture(this, 640, 480);
  video.start();
 
  prevFrame = createImage(640, 480, RGB);
  currentFrame = createImage(640, 480, RGB);
}
 
void draw() {
  //background(0);
  
  if (armDetect) {
    detect();
    armDetect = false;
  }
  
  //image(currentFrame, 0, 0);
}
 
void captureEvent(Capture video) {
  if (firstRun) {
    prevFrame.copy(video, 0, 0, 640, 480, 0, 0, 640, 480);
    firstRun = false;
  } else {
    prevFrame.copy(currentFrame, 0, 0, 640, 480, 0, 0, 640, 480);
  }
  
  currentFrame.copy(video, 0, 0, 640, 480, 0, 0, 640, 480);
    
  armDetect = true;
}

void detect() {
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

  background(0);

  for (AssociatedIndex i : matches) {       
    Point2D_F64 p0 = locations0.get(i.src); 
    Point2D_F64 p1 = locations1.get(i.dst); 
    PVector pp0 = new PVector((float) p0.x, (float) p0.y);
    PVector pp1 = new PVector((float) p1.x, (float) p1.y);
    //float diffX = (float) p1.x - (float) p0.x;
    //float diffY = (float) p1.y - (float) p0.y;     
    
    strokeWeight(10);
    stroke(255,0,0);
    point(pp0.x, pp0.y);
    stroke(0,255,0);
    point(pp1.x, pp1.y);
  }
}
