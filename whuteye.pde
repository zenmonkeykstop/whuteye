  int maxEyes = 500;
float miner = 10;
float maxer = 60;
float mFactor = 0.85;
ArrayList theEyes;
int maxTries= 10000;



void setup () {
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
 for (int i=0; i <theEyes.size(); i++) {
      eyeBall eye = (eyeBall) theEyes.get(i);
      eye.display(new PVector (mouseX, mouseY));
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
   float randomFactor = r*0.01;
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