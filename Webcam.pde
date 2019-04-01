import processing.video.*;

Capture video;
PImage videoFrame;
String[] cameraNames;
boolean frameReceived = false;

void setupWebcam(int w, int h, int cam) {
  println("Available cameras:");
  cameraNames = Capture.list();
  printArray(cameraNames);
  
  video = new Capture(this, w, h, cameraNames[cam]);
  video.start();
  videoFrame = createImage(video.width, video.height, RGB);
}

void setupWebcam(int w, int h, String cam, int fps) {
  video = new Capture(this, w, h, "name=" + cam + ",size=" + w + "x" + h + ",fps=" + fps);
  video.start();
  videoFrame = createImage(video.width, video.height, RGB);
}

void captureEvent(Capture video) {
  videoFrame.copy(video, 0, 0, video.width, video.height, 0, 0, video.width, video.height);
    
  frameReceived = true;
}
