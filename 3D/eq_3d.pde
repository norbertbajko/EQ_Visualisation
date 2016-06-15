import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.*;

Minim minim;
AudioPlayer song;
BeatDetect beat;
FFT fft;

// parameters
int amplification = 85;  // HAVE TO ADJUST THIS FOR EVERY SONG
int ghost = 1;
int step = 5;
int interlacing = 1;
int delay = 0;
boolean sliding = false;
int shift_number = 0;
int max_past_number = 300;
float defY = 30;

// variables
float w;
int clear = 0;
int step_status = 0;
int alpha = 0;
List < List < Point >> past = new ArrayList < List < Point >> ();
int past_number = 1;
boolean first_draw = true;
int shift = 0;
float maxY = 0;


public class Point {
  Float x;
  Float y;

  public Point(float a, float b) {
    this.x = a;
    this.y = b;
  }

  public float getX() {
    return this.x;
  }

  public float getY() {
    return this.y;
  }
}

void setup() {
  //delay(5000);
  frameRate(60);
  size(800, 600, P3D);
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

  camera(100.0, 0.0, 700.0, // eyeX, eyeY, eyeZ
    0.0, 350.0, -200.0, // centerX, centerY, centerZ
    0.0, 1.0, 0.0); // upX, upY, upZ
  translate(-625, -25, 0); // move the grapgic to the perfect position
  scale(1.5, 1.0, 1.0); // wider graphic

  alpha += 255 / ghost;
  stroke(alpha);
  clear++;
  fft.forward(song.mix);
  List < Point > points = new ArrayList < Point > ();
  points.add(new Point(float(0), float(height)));
  float max = fft.avgSize();
  if (!sliding || step < 3) {
    step_status = 0;
  }
  //maxY=defY;
  for (int i = 0; i < max; i++) {
    if (i * w <= width) {
      if (step_status == step) {
        strokeWeight(w / 4);
        float Y = fft.getAvg(i);
        float y2 = 1 + height - Y * amplification * (((i + (max / 4)) / max) * ((i + (max / 4)) / max));
        //float y2 = 1+height-Y*(5000/(maxY*2))*(((i+(max/4))/max)*((i+(max/4))/max));
        /*if (Y>maxY){
         maxY=Y;
         }*/
        //y2 = height-fft.getAvg(i)*50;
        /*stroke((((height-y2)/height))*255*20);
         line(i*w, height, i*w, y2);*/
        /*strokeWeight(w/4);
         point(i*w, y2);*/
        points.add(new Point(i * w, y2));
        step_status = 0;
      } else {
        step_status++;
      }
    }
  }
  //System.out.println(maxY);
  points.add(new Point(float(width), float(height)));
  strokeWeight(w / 4);

  //if first draw
  if (first_draw) {
    past.add(points);
    first_draw = false;
  } else {
    past.set(0, points);
  }

  for (int index = 0; index < past_number; index++) {
    for (int k = 1; k <= interlacing; k++) {
      for (int i = 0; i < past.get(index).size() - k; i++) {
        if (past.get(index).get(i).getY() > past.get(index).get(i + k).getY()) {
          stroke((((height - past.get(index).get(i + k).getY()) / height)) * 255 * 2);
        } else {
          stroke((((height - past.get(index).get(i).getY()) / height)) * 255 * 2);
        }
        float index_i_X = past.get(index).get(i).getX();
        float index_i_Y = min(height, past.get(index).get(i).getY() + (index * 8));
        float index_Z = float(50 * (index) * -1);
        float index_1_Z = float(50 * (index - 1) * -1);

        line(index_i_X, index_i_Y, index_Z, past.get(index).get(i + k).getX(), min(height, past.get(index).get(i + k).getY() + (index * 8)), index_Z);
        if (index > 0) {
          line(index_i_X, index_i_Y, index_Z, past.get(index - 1).get(i + k).getX(), min(height, past.get(index - 1).get(i + k).getY() + (index * 8)), index_1_Z);
          line(index_i_X, index_i_Y, index_Z, past.get(index - 1).get(i).getX(), min(height, past.get(index - 1).get(i).getY() + (index * 8)), index_1_Z);
        }
      }
    }
  }

  if (shift == shift_number) {
    shift = 0;
    if (past_number < max_past_number) {
      past_number++;
      past.add(points);
    }

    for (int index = past_number - 1; index > 0; index--) {
      past.set(index, past.get(index - 1));
    }
  } else {
    shift++;
  }
}