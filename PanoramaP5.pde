// https://forum.processing.org/two/discussion/21046/panorama-using-a-webcam

import boofcv.processing.*;
import boofcv.struct.image.*;
import boofcv.struct.feature.*;
import georegression.struct.point.*;
import java.util.*;
import processing.video.*;
 
Capture video;
 
PImage prevFrame;
PImage current;
 
int read = 0;
int c = 1;
float avgX = 0;
float avgY = 0;
boolean reading1 = false;
float stores1 = 0;
 
List<Point2D_F64> locations0, locations1;      // feature locations
List<AssociatedIndex> matches;      // which features are matched together
 
void setup() {
  size(1600, 800, P2D);
  video = new Capture(this, 1024, 768);
  video.start();
 
  prevFrame = createImage(624, 668, RGB);
  current = createImage(624, 668, RGB);
}

void detect() {
  SimpleDetectDescribePoint ddp = Boof.detectSurf(true, ImageDataType.F32);  //usar SURF
  SimpleAssociateDescription assoc = Boof.associateGreedy(ddp, true);  // busca interminavel
 
  // Find the features
  ddp.process(prevFrame);
  locations0 = ddp.getLocations();
  List<TupleDesc> descs0 = ddp.getDescriptions();
 
  ddp.process(current);
  locations1 = ddp.getLocations();
  List<TupleDesc> descs1 = ddp.getDescriptions();
 
  // associar os pontos
  assoc.associate(descs0, descs1);
  matches = assoc.getMatches();
}
 
void draw() {
  detect();
  int count = 0;
  for (AssociatedIndex i : matches) {     
    if (count++ % 30 != 0) {
      continue;
    } else if (count > 700) {       
      break;
    }
    
    Point2D_F64 p0 = locations0.get(i.src); 
    Point2D_F64 p1 = locations1.get(i.dst); 
    float diffX = (float) p1.x - (float)p0.x;
    float diffY = (float) p1.y - (float)p0.y;    
 
    if (read < 20) {
      if (diffY < 15) {
        avgX = avgX + (diffX - avgX)/c;
        avgY = avgY + (diffY - avgY)/c;
        image(prevFrame,0,0);
        image(current,320,0);
        c++;
      }
    }
 
    if ( read == 19) {    
      translation();
    }
    
    read++;
  }
}
 
void translation() {
  if (abs(avgX) > 20) {
    stores1 = stores1 - avgX;
    image( current, 640+stores1, 180);
    prevFrame.copy(video, 200, 300, 824, 368, 0, 0, 320, 240);
  }
 
  println(avgX);
  c=1;
  read = 0;
  avgX = avgY = 0;
}
 
void captureEvent(Capture video) {
  video.read();
  current.copy(video, 200, 300, 824, 368, 0, 0, 320, 240);
 
  if (reading1 == false) {
    prevFrame.copy(video, 200, 300, 824, 368, 0, 0, 320, 240); 
    reading1 = true;
  }
}
