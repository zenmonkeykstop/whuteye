import gab.opencv.*;
import processing.video.*;
import java.awt.*;

boolean displayVideo = false;

int maxEyes = 150;
float miner = 60;
float maxer = 80;
float mFactor = 0.85;
ArrayList theEyes;
int maxTries= 10000;
PVector myPos;
PVector relaxPos;

int vidW = 320;
int vidH = 240;


Capture video;
OpenCV opencv;

// Events
void keyPressed()
{
  if (key == 'v') displayVideo = !displayVideo;
}


void setup () {
  myPos = new PVector (displayWidth/2, displayHeight/2);
  relaxPos = new PVector (displayWidth/2, displayHeight/2);
  video = new Capture(this, vidW, vidH);
  opencv = new OpenCV(this, vidW, vidH);
  opencv.loadCascade(OpenCV.CASCADE_FRONTALFACE); 
 
  video.start(); 
  
  size (displayWidth, displayHeight, P2D);
  theEyes = new ArrayList();
  int safetyNet = 0;
  while (theEyes.size() < maxEyes) {
    maxTries--;
    safetyNet++;
    if (safetyNet >= 1000) {
      // print ("hit net!!! shrinking eyeballs.\n"); 
      maxer = max (10, maxer*0.8); 
      miner = max (10, miner*0.8); 
      safetyNet = 0;
    }
    
    if (maxTries <=0) { 
    //print ("hit ultimate limit!\n"); 
      break; 
      }

    float tr = random (miner, maxer);
    PVector tc = new PVector (random (tr/mFactor, width - tr/mFactor), random (tr/mFactor, height - tr/mFactor));
    boolean noOverlap = true;
    for (int i=0; i <theEyes.size(); i++) {
      eyeBall eye = (eyeBall) theEyes.get(i);
      if (tc.dist(eye.wc) < (eye.r + tr+2)) { noOverlap = false; }
    }
    if (noOverlap)  { theEyes.add (new eyeBall (tc, tr)); }
  }
//print ("got " +theEyes.size() + " eyes in the end...");
}

void draw () {
 background (255,210, 200);
 
 // detect faces
 opencv.loadImage(video);
 Rectangle[] faces = opencv.detect();
 println(faces.length);
 
 // average position of the faces, or just relax back to center
 if (faces.length > 0) {
   myPos.set(0,0);
   for (int i=0; i< faces.length; i++) {
     PVector r =  new PVector(faces[i].x + (faces[i].width/2), faces[i].y + (faces[i].height/2));
     myPos.add(r);
   }
   myPos.div(faces.length);
   myPos.set(abs(myPos.x*(displayWidth/vidW) - displayWidth), myPos.y*(displayHeight/vidH));
 } else { 
   PVector theDiff = PVector.sub(myPos, relaxPos);
   //theDiff = relaxPos; 
   theDiff = PVector.mult(theDiff, -0.1);
   myPos = PVector.add (myPos, theDiff);
 }
 
 for (int i=0; i <theEyes.size(); i++) {
      eyeBall eye = (eyeBall) theEyes.get(i);
      eye.display(myPos);
 }
 // scale(2);
 if (displayVideo){
   image(video, 0, 0 );
   noFill();
    stroke(0, 255, 0);
    strokeWeight(1);
    println(faces.length);

    for (int i = 0; i < faces.length; i++) {
      rect(faces[i].x, faces[i].y, faces[i].width, faces[i].height);
    }
   }

}

class eyeBall {
  color ic;
 float r;
 // iris radius is 50% of whites, pupil is 20%
 PVector wc;
  
 eyeBall (PVector myCentre, float myRadius) {
  ic = color (random(50, 200), random(100, 200), random(100,200));
  wc = myCentre;
  r = myRadius;
 }
 
 void display(PVector gd) {
   float randomFactor = r*0.005;
   noStroke();
   fill (255,245,245);
   ellipse (wc.x, wc.y, r*2, r*2);
   
   PVector d;
   if (gd.dist(wc) < (r/2)) {
     d = new PVector (gd.x + random(-1*randomFactor, randomFactor), gd.y + random(-1*randomFactor, randomFactor));
   } else {
     d = new PVector ((r/2)*( (gd.x - wc.x)/gd.dist(wc)) + wc.x  + random(-1*randomFactor, randomFactor), (r/2)*((gd.y - wc.y)/gd.dist(wc)) + wc.y  + random(-1*randomFactor, randomFactor) );
   }

   
   pushMatrix ();
   translate (d.x, d.y);
   //PVector hNormal = new PVector (0, 1); 
   //rotate (PVector.angleBetween(hNormal, PVector.sub(d, wc)));
   //scale (sin(PVector.angleBetween(hNormal, PVector.sub(d, wc))), 1 - cos(PVector.angleBetween(hNormal, PVector.sub(d, wc))));
   
   fill(ic);
   ellipse (0.0, 0.75*d.dist(wc)/r, r, r);
   fill(0);
   ellipse (0,0.75*d.dist(wc)/r, r/2, r/2);
   popMatrix();
   fill (255, 200);
   ellipse (wc.x + r*-0.4, wc.y+ r*-0.4, r*0.6, r*0.6);
 }
}
