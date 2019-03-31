import boofcv.processing.*;
import boofcv.struct.image.*;
import boofcv.struct.feature.*;
import georegression.struct.point.*;
import java.util.*;
import processing.video.*;
 
Capture video;
 
PImage prevFrame;
PImage current;
 
int leu = 0;
int c = 1;
float avgX = 0;
float avgY = 0;
boolean leitura1 = false;
float armazena1 = 0;
 
 
List<Point2D_F64> locations0, locations1;      // feature locations
List<AssociatedIndex> matches;      // which features are matched together
 
 
void setup() {
 
  size(1600, 800);
  video = new Capture(this, 1024, 768);
  video.start();
 
  prevFrame = createImage(624, 668, RGB);
  current = createImage(624, 668, RGB);
}
void detectar() {
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
  detectar();
  int count = 0;
  for ( AssociatedIndex i : matches  ) {     
    if ( count++ % 30 != 0 )
      continue;
    else if ( count > 700)
    {       
      break;
    }
    Point2D_F64 p0 = locations0.get(i.src); 
    Point2D_F64 p1 = locations1.get(i.dst); 
    float diferencaX = (float) p1.x - (float)p0.x;
    float diferencaY = (float) p1.y - (float)p0.y;    
 
    if (leu < 20) {
 
      if (diferencaY < 15) {
        avgX = avgX + (diferencaX - avgX)/c;
        avgY = avgY + (diferencaY - avgY)/c;
        //image(prevFrame,0,0);
        //image(current,320,0);
        c++;
      }
    }
 
    if ( leu == 19) {    
      translacao();
    }
    leu++;
  }
}
 
 
void translacao() {
  if (abs(avgX) > 20) {
    armazena1 = armazena1 - avgX;
    image( current, 640+armazena1, 180);
    prevFrame.copy(video, 200, 300, 824, 368, 0, 0, 320, 240);
  }
 
  println(avgX);
  c=1;
  leu = 0;
  avgX = avgY = 0;
}
 
void captureEvent(Capture video) {
 
  video.read();
  current.copy(video, 200, 300, 824, 368, 0, 0, 320, 240);
 
  if ( leitura1 == false) {
    prevFrame.copy(video, 200, 300, 824, 368, 0, 0, 320, 240); 
    leitura1 = true;
  }
}
