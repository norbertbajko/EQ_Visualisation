import ddf.minim.*;
import ddf.minim.analysis.*;
import java.util.*;

Minim minim;
AudioPlayer song;
FFT fft;

// parameters
int amplification = 100;  // HAVE TO ADJUST THIS FOR EVERY SONG
int step = 5;
int interlacing = 1;
int max_past_number = 500;
int speed = 50;

// variables
float w;
int past_number = 0;
List < List < Point >> past = new ArrayList < List < Point >> ();
List < Point > points = new ArrayList < Point > ();
boolean first_draw = true;



public class Point {
  public Float x;
  public Float y;

  public Point(float a, float b) {
    this.x = a;
    this.y = b;
  }
}

void setup() {
  frameRate(60);
  size(1200, 900, P3D);
  minim = new Minim(this);

  try {
    song = minim.loadFile("rise.mp3", 512);
  }
  catch (Exception ex) {
    System.out.println("error:" + ex);
  };

  fft = new FFT(song.bufferSize(), song.sampleRate());
  fft.logAverages(1000, 50);
  System.out.println(fft.avgSize());
  w = width / fft.avgSize() * 1.4;
  stroke(255);
  strokeWeight(w / 4);
  song.loop();

  points = new ArrayList < Point > ();
  points.add(new Point(float(0), float(height)));
  for (int i = 0; i < max_past_number; i++) {
    past_number++;
    past.add(points);
  }
}


void draw() {
  background(0);

  camera(
    100.0, 0.0, 700.0, // eyeX, eyeY, eyeZ
    0.0, 300.0, 0.0, // centerX, centerY, centerZ
    0.0, 1.0, 0.0); // upX, upY, upZ
  translate(-1000, 200, -500); // move the grapgic to the perfect position
  scale(1.5, 1.0, 1.0); // wider graphic


  fft.forward(song.mix);

  points = new ArrayList < Point > ();
  points.add(new Point(float(0), float(height)));

  float max = fft.avgSize();
  int step_status = 0;

  for (int i = 0; i < max; i++) {
    if (i * w <= width) {
      if (step_status == step) {
        float Y = fft.getAvg(i);
        float y2 = 1 + height - Y * amplification * (((i + (max / 4)) / max) * ((i + (max / 4)) / max));
        points.add(new Point(i * w, y2));
        step_status = 0;
      } else {
        step_status++;
      }
    }
  }

  points.add(new Point(float(width), float(height)));

  if (first_draw) {
    past.add(points);
    first_draw = false;
  } else {
    past.set(0, points);
  }

  for (int index = 0; index < max_past_number; index++) {
    for (int k = 1; k <= interlacing; k++) {
      for (int i = 0; i < past.get(index).size() - k; i++) {
        float amp = min(past.get(index).get(i).y, past.get(index).get(i + k).y);
        stroke((((height - amp) / height)) * 255 * 1.25);
        float index_i_X = past.get(index).get(i).x;
        float index_i_Y = min(height, past.get(index).get(i).y + (index * 8));
        float index_Z = float(speed * (index) * -1);
        float index_1_Z = float(speed * (index - 1) * -1);

        line(index_i_X, index_i_Y, index_Z, past.get(index).get(i + k).x, min(height, past.get(index).get(i + k).y + (index * 8)), index_Z);
        if (index > 0) {
          line(index_i_X, index_i_Y, index_Z, past.get(index - 1).get(i + k).x, min(height, past.get(index - 1).get(i + k).y + (index * 8)), index_1_Z);
          line(index_i_X, index_i_Y, index_Z, past.get(index - 1).get(i).x, min(height, past.get(index - 1).get(i).y + (index * 8)), index_1_Z);
        }
      }
    }
  }

  for (int index = max_past_number - 1; index > 0; index--) {
    past.set(index, past.get(index - 1));
  }
}
