/*
                    Amplitude and Frequency Modulation
                    ----------------------------------
   Description
   
*/


// Global Constants

// Global Variables
final int GAP = 50;
float xspacing = 0.5;
int signal_width;              // Width of entire wave
int maxwaves = 10;   // total # of waves to add together
float[] message_amplitude = new float[maxwaves];
float[] message_dx = new float[maxwaves];

final float F_CARRIER = 40;
final float F_MESSAGE = 2;
final float DELTA_THETA = 0.01;

float theta = 0.0;  // Start angle at 0
float carrier_amplitude = 80.0;  // Height of wave
float period = 500.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] carrier_y;  // Using an array to store height values for the wave
float[] message_y;
float[] am_y, fm_y;



void setup() {
  size(1080, 1080);
  pixelDensity(displayDensity());
  
  signal_width = width/4;
  dx = (TWO_PI / period) * xspacing;
  int array_size = int(signal_width/xspacing);
  carrier_y = new float[array_size];
  message_y = new float[array_size];
  am_y = new float[array_size];
  fm_y = new float[array_size];
  
  initMessageAmplitudes();
 
} // End of setup()



void draw() {
  background(0);
  //calcCarrier();
  calcSignals();
  renderSignals();

} // End of draw()

void initMessageAmplitudes() {
   for (int i = 0; i < maxwaves; i++) {
    message_amplitude[i] = random(5,15);
    float period = random(100,300); // How many pixels before the wave repeats
    message_dx[i] = (TWO_PI / period) * xspacing;
  }
}

void calcSignals() {
  // Increment theta (try different values for 'angular velocity' here
  theta += DELTA_THETA;
  float x = theta;
  // Set all height values to zero
  for (int i = 0; i < message_y.length; i++) {
    
    message_y[i] = 0;
    
    x+=dx;
  }
 
  // Accumulate wave height values
  for (int j = 0; j < maxwaves; j++) {
    x = theta;
    for (int i = 0; i < message_y.length; i++) {
      // Every other wave is cosine instead of sine
      if (j % 2 == 0)  message_y[i] += sin(F_MESSAGE*x)*message_amplitude[j];
      else message_y[i] += cos(F_MESSAGE*x)*message_amplitude[j];
      //message_y[i] = sin(F_MESSAGE*x)*message_amplitude[j];
      x+=message_dx[j];
    }
  }
  
  x = theta;
  for (int i = 0; i < am_y.length; i++) {
    // CARRIER
    carrier_y[i] = sin(F_CARRIER*x)*carrier_amplitude;
    
    // AM
    float mod_index = max(message_y)/carrier_amplitude;
    println(mod_index);
    //am_y = (1+message_y[i]) * carrier_amplitude;
    am_y[i] = (1-message_y[i]/carrier_amplitude)*carrier_amplitude*sin(F_CARRIER*x);
    
    float f = map(message_y[i], 0, 100, 1, 80);
    fm_y[i] = carrier_amplitude*sin(f*x);
    
    x+=dx;
  }
  
  
}

void renderSignals() {
  // A simple way to draw the wave with an ellipse at each location
  for (int x = 1; x < carrier_y.length; x++) {
    // Carrier
    stroke(255);
    line((x-1)*xspacing+width/2 - signal_width/2, height/2 + carrier_y[x-1], x*xspacing+width/2 - signal_width/2, height/2+carrier_y[x]);
    
    // Message
    line((x-1)*xspacing + GAP, height/2 + message_y[x-1], x*xspacing + GAP, height/2 + message_y[x]);
    
    // AM
    line((x-1)*xspacing+width - GAP -signal_width, height/4 + am_y[x-1], x*xspacing+width - GAP -signal_width, height/4+am_y[x]);
    if ((x / 5) % 2 == 0){
      stroke(#FF0000);
      line((x-1)*xspacing+width - GAP - signal_width, height/4 + message_y[x-1] - carrier_amplitude, x*xspacing+width - GAP -signal_width, height/4+message_y[x]-carrier_amplitude);
    }
    
    // FM
    stroke(255);
    line((x-1)*xspacing+width - GAP -signal_width, 3*height/4 + fm_y[x-1], x*xspacing+width - GAP -signal_width, 3*height/4+fm_y[x]);
  }
}
