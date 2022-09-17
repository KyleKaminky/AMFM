/*
                           TITLE
                           ----------------
   Description
   
*/


// Global Constants

// Global Variables
float xspacing = 0.5;
int w;              // Width of entire wave
int maxwaves = 10;   // total # of waves to add together
float[] message_amplitude = new float[maxwaves];
float[] message_dx = new float[maxwaves];

final float F_CARRIER = 50;
final float F_MESSAGE = 2;
final float DELTA_THETA = 0.001;

float theta = 0.0;  // Start angle at 0
float carrier_amplitude = 75.0;  // Height of wave
float period = 500.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] carrier_y;  // Using an array to store height values for the wave
float[] message_y;
float[] am_y, fm_y;



void setup() {
  //frameRate(25);
  size(1080, 1080);
  pixelDensity(displayDensity());
  
  w = width/4;
  dx = (TWO_PI / period) * xspacing;
  carrier_y = new float[int(w/xspacing)];
  message_y = new float[int(w/xspacing)];
  am_y = new float[int(w/xspacing)];
  fm_y = new float[int(w/xspacing)];
  
  initMessageAmplitudes();
 
} // End of setup()



void draw() {
  background(0);
  calcCarrier();
  calcMessage();
  calcAM();
  renderWave();

} // End of draw()

void initMessageAmplitudes() {
   for (int i = 0; i < maxwaves; i++) {
    message_amplitude[i] = random(10,30);
    float period = random(100,300); // How many pixels before the wave repeats
    message_dx[i] = (TWO_PI / period) * xspacing;
  }
}

void calcMessage() {
  // Increment theta (try different values for 'angular velocity' here
  theta += DELTA_THETA;

  // Set all height values to zero
  for (int i = 0; i < message_y.length; i++) {
    message_y[i] = 0;
  }
 
  // Accumulate wave height values
  for (int j = 0; j < maxwaves; j++) {
    float x = theta;
    for (int i = 0; i < message_y.length; i++) {
      // Every other wave is cosine instead of sine
      if (j % 2 == 0)  message_y[i] += sin(F_MESSAGE*x)*message_amplitude[j];
      else message_y[i] += cos(F_MESSAGE*x)*message_amplitude[j];
      x+=message_dx[j];
    }
  }
}

void calcCarrier() {
  // Increment theta (try different values for 'angular velocity' here
  theta += DELTA_THETA;

  // For every x value, calculate a y value with sine function
  float x = theta;
  for (int i = 0; i < carrier_y.length; i++) {
    
    carrier_y[i] = sin(F_CARRIER*x)*carrier_amplitude;
    
    x+=dx;
  }
}

void calcAM() {
  // Increment theta (try different values for 'angular velocity' here
  theta += DELTA_THETA;

  // For every x value, calculate a y value with sine function
  float x = theta;
  for (int i = 0; i < am_y.length; i++) {
    float amplitude = message_y[i];
    am_y[i] = sin(F_CARRIER*x)*amplitude;
    
    x+=dx;
  }
  
}

void calcFM() {
  
  
}

void renderWave() {
  
  stroke(255);
  // A simple way to draw the wave with an ellipse at each location
  for (int x = 1; x < carrier_y.length; x++) {
    line((x-1)*xspacing+width/2, height/2 + carrier_y[x-1], x*xspacing+width/2, height/2+carrier_y[x]);
    line((x-1)*xspacing+width/2, height/4 + message_y[x-1], x*xspacing+width/2, height/4+message_y[x]);
    line((x-1)*xspacing+width/2, 3*height/4 + am_y[x-1], x*xspacing+width/2, 3*height/4+am_y[x]);
    
    //ellipse(x*xspacing, height/2+carrier_y[x], 5, 5);
  }
}
