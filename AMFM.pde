/*
                    Amplitude and Frequency Modulation
                    ----------------------------------
   Description
   
*/


// Global Constants
final int BG_COLOR = #1D1D1D;
final int FRAMEWORK_COLOR = #FFFAFB;
final int MESSAGE_COLOR = #8B80F9;//#80475E;
final int AM_COLOR = #339989;
final int FM_COLOR = #80475E;
final int CARRIER_COLOR = #FFFAFB;

final int TRIANGLE_SIZE = 10;
final int MIXER_SIZE = 1080/15;
final int WIDTH = 1080/3;
final int AMPLITUDE = 0;
final String TITLE = "Amplitude (AM) & Frequency (FM) Modulation";
final int TITLE_Y = 50;
final float FM_Y = 1080*3/4;
final float AM_Y = 1080*1/4;
final int DASHED_LINE = 15;

// Global Variables
final int GAP = 50;
float xspacing = 0.5;
int signal_width;              // Width of entire wave
int maxwaves = 4;   // total # of waves to add together
float[] message_amplitude = new float[maxwaves];
float[] message_frequencies = new float[maxwaves];
final float F_MESSAGE_MAX = 2;
final float F_MESSAGE_MIN = 0.1;
//float[] message_dx = new float[maxwaves];
final float K_f = 0.01;

final float F_CARRIER = 10;
final float DELTA_THETA = 0.005;

float theta = 0.0;  // Start angle at 0
float carrier_amplitude = 80.0;  // Height of wave
float period = 1000.0;  // How many pixels before the wave repeats
float dx;  // Value for incrementing X, a function of period and xspacing
float[] carrier_y;  // Using an array to store height values for the wave
float[] message_y;
float[] am_y, fm_y;

int line_x_start, line_x_finish, line_x_temp_finish;
int line_y_start, line_y_finish, line_y_temp_finish;
int signals_opacity = 0;
int title_opacity = 0;
int output_line_x_start, output_line_x_finish, output_line_x_temp_finish;
int framework_opacity = 0;

String state;

void setup() {
  size(1080, 1080);
  pixelDensity(displayDensity());
  textAlign(CENTER, CENTER);
  
  signal_width = width/4;
  dx = (TWO_PI / period) * xspacing;
  int array_size = int(signal_width/xspacing);
  carrier_y = new float[array_size];
  message_y = new float[array_size];
  am_y = new float[array_size];
  fm_y = new float[array_size];
  
  initMessageAmplitudes();
  
  initLines();
  state = "initialize";
 
} // End of setup()



void draw() {
  background(BG_COLOR);
  
  switch(state) {
    case "title":
    
    
      break;
      
      
    case "initialize":
      drawFramework(framework_opacity);
      framework_opacity = framework_opacity >= 255 ? 255: framework_opacity + 5;
      
      if (framework_opacity == 255) {
        state = "draw";
      }
    
      break;
      
      
    case "draw":
      signals_opacity = signals_opacity >= 255 ? 255: signals_opacity + 5;
      drawFramework(255);
      calcSignals();
      renderSignals(signals_opacity);
      break;
    
    
  }
 

} // End of draw()



// ---------- drawFramework() ---------
void drawFramework(int m_opacity) {
  fill(FRAMEWORK_COLOR, 255);
  stroke(FRAMEWORK_COLOR, 255);
  strokeWeight(3);
  textSize(40);
  text(TITLE, width/2, TITLE_Y);
  line(width/2 - textWidth(TITLE)/2, TITLE_Y + textAscent(), width/2 + textWidth(TITLE)/2, TITLE_Y + textAscent());
  
  stroke(FRAMEWORK_COLOR, m_opacity);
  fill(FRAMEWORK_COLOR, m_opacity);
  textSize(20);
  text("Message Signal", GAP + signal_width/2, height/2 + carrier_amplitude);
  text("Carrier Signal", width/2, height/2 + carrier_amplitude*1.2);
  text("AM Signal", width - GAP - signal_width/2, AM_Y + carrier_amplitude*1.5);
  text("FM Signal", width - GAP - signal_width/2, FM_Y + carrier_amplitude*1.2);
  text("Amplitude Modulator", width/2, AM_Y - MIXER_SIZE);
  text("Frequency Modulator", width/2, FM_Y + MIXER_SIZE);
  
  fill(BG_COLOR, 255);
  strokeWeight(3);
  float mixer_offset = MIXER_SIZE/2 * cos(PI/4);
  
  // AM Mixer
  circle(width/2, AM_Y, MIXER_SIZE);
  line(width/2 - mixer_offset, AM_Y - mixer_offset, width/2 + mixer_offset, AM_Y + mixer_offset);
  line(width/2 - mixer_offset, AM_Y + mixer_offset, width/2 + mixer_offset, AM_Y - mixer_offset);
  
  // FM Mixer
  circle(width/2, FM_Y, MIXER_SIZE);
  line(width/2 - mixer_offset, FM_Y - mixer_offset, width/2 + mixer_offset, FM_Y + mixer_offset);
  line(width/2 - mixer_offset, FM_Y + mixer_offset, width/2 + mixer_offset, FM_Y - mixer_offset);
  
 
  stroke(FRAMEWORK_COLOR, m_opacity);
  line(line_x_start, AM_Y, line_x_finish, AM_Y);
  line(line_x_start, FM_Y, line_x_finish, FM_Y);
  line(line_x_start, line_y_start, line_x_start, line_y_finish);
  line(line_x_start, height - line_y_start, line_x_start, width - line_y_finish);
  
  
  // Vertical lines from carrier
  line(width/2, height/2 - carrier_amplitude*1.2, width/2, AM_Y + MIXER_SIZE/2);
  line(width/2, height/2 + carrier_amplitude*1.5, width/2, FM_Y - MIXER_SIZE/2);
  
  // Output lines
  line(width/2 + MIXER_SIZE/2, AM_Y, width - GAP - signal_width*1.1, AM_Y);
  line(width/2 + MIXER_SIZE/2, FM_Y, width - GAP - signal_width*1.1, FM_Y);
  
  fill(FRAMEWORK_COLOR, m_opacity);
  float x_1 = width/2 - TRIANGLE_SIZE - MIXER_SIZE/2;
  float y_1 = AM_Y - TRIANGLE_SIZE/2;
  float x_2 = width/2 - TRIANGLE_SIZE - MIXER_SIZE/2;
  float y_2 = AM_Y + TRIANGLE_SIZE/2;
  float x_3 = width/2 - MIXER_SIZE/2-2;
  float y_3 = AM_Y;
  triangle(x_1, y_1, x_2, y_2, x_3, y_3);
  triangle(x_1, height - y_1, x_2, height - y_2, x_3, height - y_3);
  
  x_1 = width/2 - TRIANGLE_SIZE/2;
  y_1 = AM_Y + MIXER_SIZE/2 + TRIANGLE_SIZE;
  x_2 = width/2 + TRIANGLE_SIZE/2;
  y_2 = AM_Y + MIXER_SIZE/2 + TRIANGLE_SIZE;
  x_3 = width/2;
  y_3 = AM_Y + MIXER_SIZE/2 + 3;
  triangle(x_1, y_1, x_2, y_2, x_3, y_3);
  triangle(x_1, height - y_1, x_2, height - y_2, x_3, height - y_3);
  
  x_1 = width - GAP - signal_width*1.1 - TRIANGLE_SIZE;
  y_1 = AM_Y + TRIANGLE_SIZE/2;
  x_2 = width - GAP - signal_width*1.1 - TRIANGLE_SIZE ;
  y_2 = AM_Y - TRIANGLE_SIZE/2;
  x_3 = width - GAP - signal_width*1.1;
  y_3 = AM_Y;
  triangle(x_1, y_1, x_2, y_2, x_3, y_3);
  triangle(x_1, height - y_1, x_2, height - y_2, x_3, height - y_3);
  

} // End of drawFramework()



void initLines() {
  line_x_start = GAP + signal_width/2;
  line_x_finish = width/2 - MIXER_SIZE/2;
  
  line_y_start = height/2 - int(carrier_amplitude) - 30;
  line_y_finish = int(AM_Y);
  
  output_line_x_start = width/2 + MIXER_SIZE/2;
  output_line_x_finish = width - width/12 - WIDTH;
  output_line_x_temp_finish = output_line_x_start;

  
}

void initMessageAmplitudes() {
   for (int i = 0; i < maxwaves; i++) {
    message_amplitude[i] = random(10,20);
    //message_amplitude[i] = 5;
    //float period = random(100,300); // How many pixels before the wave repeats
    message_frequencies[i] = random(F_MESSAGE_MIN, F_MESSAGE_MAX);
  }
}

void calcSignals() {
  // Increment theta (try different values for 'angular velocity' here
  theta += DELTA_THETA;
  float x = theta;
  // Set all height values to zero
  for (int i = 0; i < message_y.length; i++) {
    message_y[i] = 0;
  }

  // Accumulate wave height values
  for (int j = 0; j < maxwaves; j++) {
    x = theta;
    for (int i = 0; i < message_y.length; i++) {
      // Every other wave is cosine instead of sine
      if (j % 2 == 0)  message_y[i] += sin(2*PI*message_frequencies[j]*x)*message_amplitude[j];
      else message_y[i] += cos(2*PI*message_frequencies[j]*x)*message_amplitude[j];
      
      x+=dx;
    }
  }
  
  x = theta;
  float sum = 0.0;
  for (int i = 0; i < am_y.length; i++) {
    
    // CARRIER
    carrier_y[i] = sin(2*PI*F_CARRIER*x)*carrier_amplitude;
    
    // Calc AM
    am_y[i] = (1-message_y[i]/carrier_amplitude)*carrier_amplitude*sin(2*PI*F_CARRIER*x);
    
   // Calc FM
    sum += message_y[i]/2 - 15;
    float phi = 2*PI*F_CARRIER*x - K_f*(sum+100);
    fm_y[i] = carrier_amplitude*cos(phi);
    
    x+=dx;
  }
  
  
}

void renderSignals(int s_opacity) {
  strokeWeight(2);
  // A simple way to draw the wave with an ellipse at each location
  for (int x = 1; x < carrier_y.length; x++) {
    // Carrier
    stroke(CARRIER_COLOR, s_opacity);
    line((x-1)*xspacing+width/2 - signal_width/2, height/2 + carrier_y[x-1], x*xspacing+width/2 - signal_width/2, height/2+carrier_y[x]);
    
    // Message
    stroke(MESSAGE_COLOR, s_opacity);
    line((x-1)*xspacing + GAP, height/2 + message_y[x-1], x*xspacing + GAP, height/2 + message_y[x]);
    
    // AM
    stroke(AM_COLOR, s_opacity);
    line((x-1)*xspacing+width - GAP -signal_width, AM_Y + am_y[x-1], x*xspacing+width - GAP -signal_width, AM_Y + am_y[x]);
    if ((x / DASHED_LINE) % 2 == 0){
      stroke(MESSAGE_COLOR, s_opacity);
      line((x-1)*xspacing+width - GAP - signal_width, AM_Y + message_y[x-1] - carrier_amplitude, x*xspacing+width - GAP -signal_width, AM_Y + message_y[x]-carrier_amplitude);
    }
    
    // FM
    stroke(FM_COLOR, s_opacity);
    line((x-1)*xspacing+width - GAP -signal_width, FM_Y + fm_y[x-1], x*xspacing+width - GAP -signal_width, FM_Y+fm_y[x]);
    if ((x / DASHED_LINE) % 2 == 0){
      stroke(MESSAGE_COLOR, s_opacity);
      line((x-1)*xspacing+width - GAP - signal_width, FM_Y + message_y[x-1] - carrier_amplitude*1.5, x*xspacing+width - GAP -signal_width, FM_Y + message_y[x]-carrier_amplitude*1.5);
    }
    
  }
}
