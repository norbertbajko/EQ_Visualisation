import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.*;

Minim minim;
AudioPlayer song;
BeatDetect beat;
FFT fft;

// parameters
int amplification = 80;  // HAVE TO ADJUST THIS FOR EVERY SONG
int ghost = 1;
int step = 4;
int interlacing = 2;
int delay = 0;
boolean sliding = false;

// variables
float w;
int clear = 0;
int step_status = 0;
int alpha = 0;


void setup() {
  //delay(5000);
  frameRate(60);
  size(800, 600);
  minim = new Minim(this);
  try {
    song = minim.loadFile("music.mp3", 512);
    fft = new FFT(song.bufferSize(), song.sampleRate());
    fft.logAverages(1000, 60);
    w = width / fft.avgSize() * 1.4;
    stroke(alpha);
    strokeWeight(w / 4);
    song.loop();
  } 
  catch (Exception ex) {
    System.out.println("error:" + ex);
  };
}

void draw() {
  if (clear == ghost) {
    clear = 0;
    alpha = 0;
    delay(delay);
    background(0);
  }
  alpha += 255 / ghost;
  stroke(alpha);
  clear++;
  fft.forward(song.mix);
  List < Float > xek = new ArrayList < Float > ();
  List < Float > yok = new ArrayList < Float > ();
  xek.add(float(0));
  yok.add(float(height));
  float max = fft.avgSize();
  if (!sliding || step < 3) {
    step_status = 0;
  }
  for (int i = 0; i < max; i++) {
    if (i * w <= width) {
      if (step_status == step) {
        strokeWeight(w / 4);
        float y2 = height - fft.getAvg(i) * amplification * (((i + (max / 4)) / max) * ((i + (max / 4)) / max));
        //line(i*w, height, i*w, y2);
        /*strokeWeight(w/2);
         point(i*w, y2);*/
        xek.add(i * w);
        yok.add(y2);
        step_status = 0;
      } else {
        step_status++;
      }
    }
  }
  xek.add(float(width));
  yok.add(float(height));
  strokeWeight(w / 4);
  for (int k = 1; k <= interlacing; k++) {
    for (int i = 0; i < xek.size() - k; i++) {
      if (yok.get(i) > yok.get(i + k)) {
        stroke((((height - yok.get(i + k)) / height)) * 255 * 3);
      } else {
        stroke((((height - yok.get(i)) / height)) * 255 * 3);
      }
      line(xek.get(i), yok.get(i), xek.get(i + k), yok.get(i + k));
    }
  }
}