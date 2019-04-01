import processing.video.*;

Capture video;
PImage videoFrame;
String[] cameraNames;
boolean frameReceived = false;
int selectedCam = 0;

void debugWebcam() {
  println("Available cameras:");
  cameraNames = Capture.list();
  printArray(cameraNames);
}

void setupWebcam(int w, int h, int cam) {
  selectedCam = cam;
  cameraNames = Capture.list();
  video = new Capture(this, w, h, cameraNames[selectedCam]);
  video.start();
  videoFrame = createImage(video.width, video.height, RGB);
}

void captureEvent(Capture video) {
  videoFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
    
  frameReceived = true;
}
