/*
                           AM FM
                           -------------
 
   
*/

// Global Constants
final int WINDOW_WIDTH = 1080;
final int WINDOW_HEIGHT = 1080;
//final int NUM_BITS = 32;
final int MESSAGE_SIZE = 0;
//final int BITS_TO_SHOW = 8;
final int MESSAGE_SHOW_SIZE = 0;
final int WIDTH = WINDOW_WIDTH*4/12;
final float PERIOD = 25.0; // How many pixels before the wave repeats
final float AMPLITUDE = WINDOW_HEIGHT/12;  // Height of wave
final float DX = (TWO_PI / PERIOD); // Value for incrementing X, a function of period and xspacing
final int CARRIER_COLOR = #A85751;
final int DIGITAL_COLOR = #FFFFFF;
final int MODULATED_COLOR = #FFFFFF;
final int FRAMEWORK_COLOR = #F0F4EF;
final int MIXER_SIZE = WINDOW_HEIGHT/15;
final int BG_COLOR = #040926;
final int TRIANGLE_SIZE = 10;
final String TITLE = "Amplitude & Frequency Modulation";
final int MAX_WAVES = 4;

// Global Variables
int theta = 0;  // Start angle at 0
float[] yvalues = new float[WIDTH];  // Using an array to store height values for the wave
float[] sine_constant = new float[WIDTH];
//float[] digital_signal = new float[NUM_POINTS];
float[] message_signal = new float[WIDTH];
//float[] modulated_signal = new float[NUM_POINTS];
float[] am_signal = new float[WIDTH];
float[] fm_signal = new float[WIDTH];
//int[] bits = new int[NUM_BITS];
String state = "title";
int mixer_opacity = 0;
int signals_opacity = 0;
int title_opacity = 0;
int line_x_start, line_x_finish, line_x_temp_finish;
int line_y_start, line_y_finish, line_y_temp_finish;
int output_line_x_start, output_line_x_finish, output_line_x_temp_finish;
boolean draw_triangles = false;
float[] message_amplitude = new float[MAX_WAVES];
float[] dx = new float[MAX_WAVES];
float[] message_yvalues = new float[WIDTH];

// ---------- setup() ---------
void setup() {
  // Display setup
  size(1080, 1080);
  pixelDensity(displayDensity());
  background(BG_COLOR);
  textAlign(CENTER, CENTER);
  
  // Color setup
  stroke(CARRIER_COLOR);
 
  // Generate random bit stream
  //for (int i = 0; i < bits.length; i++) {
  //  if (i < 10) {
  //    bits[i] = 0;
  //  } else {
  //    bits[i] = int(random(2));
  //  }
  //}
  
  // Generate the digital and modulated signal from the bit stream
  float x = 0;
  for (int i = 0; i < sine_constant.length; i++) {
    sine_constant[i] = sin(x)*AMPLITUDE;
    x+=DX;
    //int index = int(i/(NUM_POINTS/NUM_BITS));
    //digital_signal[i] = bits[index];
    //modulated_signal[i] = sine_constant[i] * digital_signal[i];
    am_signal[i] = sine_constant[i] * message_signal[i];
    fm_signal[i] = sine_constant[i] * message_signal[i];
  }
  
  for (int i = 0; i < MAX_WAVES; i++) {
    message_amplitude[i] = random(10,30);
    float period = random(100,300); // How many pixels before the wave repeats
    dx[i] = (TWO_PI / period);
  }
  
  // Line setup
  line_x_start = width*5/12;
  line_x_finish = width/2;
  line_x_temp_finish = line_x_start;
  
  line_y_start = height/3;
  line_y_finish = height/2 - MIXER_SIZE/2;
  line_y_temp_finish = line_y_start;
  
  output_line_x_start = width/2 + MIXER_SIZE/2;
  output_line_x_finish = width - width/12 - WIDTH;
  output_line_x_temp_finish = output_line_x_start;

} // End of setup()


// ---------- draw() ---------
void draw() {
  
  switch(state) {
    case "title":
      background(BG_COLOR, 255);
      stroke(FRAMEWORK_COLOR, title_opacity);
      fill(FRAMEWORK_COLOR, title_opacity);
      strokeWeight(3);
      title_opacity = title_opacity >= 255 ? 255: title_opacity + 3;
      textSize(60);
      text(TITLE, width/2, height/8);
      line(width/2 - textWidth(TITLE)/2, height/8+textAscent(), width/2 + textWidth(TITLE)/2, height/8+textAscent());
       
      title_opacity = title_opacity >= 255 ? 255: title_opacity + 3;
      if (title_opacity == 255) {
        state = "initialize";
      }
      break;
      
    case "initialize":
      background(BG_COLOR, 255);
      drawFramework(mixer_opacity);
      mixer_opacity = mixer_opacity >= 255 ? 255: mixer_opacity + 5;
      line_x_temp_finish = (line_x_temp_finish >= line_x_finish) ? line_x_finish : line_x_temp_finish + 3;
      
      if (line_x_temp_finish == line_x_finish) {
        line_y_temp_finish = (line_y_temp_finish >= line_y_finish) ? line_y_finish : line_y_temp_finish + 3;
        output_line_x_temp_finish = (output_line_x_temp_finish >= output_line_x_finish) ? output_line_x_finish : output_line_x_temp_finish + 1;
      }
      
      if ((mixer_opacity == 255) && (line_y_temp_finish == line_y_finish)) {
        draw_triangles = true;
        state = "draw";
      }
      break;
    case "draw":
      background(BG_COLOR, 255);
      signals_opacity = signals_opacity >= 255 ? 255: signals_opacity + 5;
      drawFramework(255);
      calculateCarrier();
      calculateMessage();
      renderSignals(signals_opacity);
      break;
  }
 
} // End of draw()

// ---------- calculateCarrier() ---------
void calculateCarrier() {
  // Increment theta (try different values for 'angular velocity' here
  theta += 1;

  // For every x value, calculate a y value with sine function
  float x = theta;
  for (int i = 0; i < yvalues.length; i++) {
    yvalues[i] = sin(x)*AMPLITUDE;
    x+=DX;
  }
} // End of calculateCarrier()

void calculateMessage() {
  theta += 0.02;

  // Set all height values to zero
  for (int i = 0; i < yvalues.length; i++) {
    message_yvalues[i] = 0;
  }
 
  // Accumulate wave height values
  for (int j = 0; j < MAX_WAVES; j++) {
    float x = theta;
    for (int i = 0; i < message_yvalues.length; i++) {
      // Every other wave is cosine instead of sine
      if (j % 2 == 0)  message_yvalues[i] += sin(x)*message_amplitude[j];
      else message_yvalues[i] += cos(x)*message_amplitude[j];
      x+=dx[j];
    }
  }
} // End of calculateMessage()

// ---------- drawFramework() ---------
void drawFramework(int m_opacity) {
  fill(FRAMEWORK_COLOR, 255);
  stroke(FRAMEWORK_COLOR, 255);
  strokeWeight(3);
  textSize(60);
  text(TITLE, width/2, height/8);
  line(width/2 - textWidth(TITLE)/2, height/8 + textAscent(), width/2 + textWidth(TITLE)/2, height/8 + textAscent());
  
  stroke(FRAMEWORK_COLOR, m_opacity);
  fill(FRAMEWORK_COLOR, m_opacity);
  textSize(40);
  text("Digital Message", width/15 + WIDTH/2, height/3 + AMPLITUDE);
  text("Carrier Signal", width/15 + WIDTH/2, height*2/3 + AMPLITUDE*1.5);
  text("Modulated Signal", width - width/15 - WIDTH/2, height/2 + AMPLITUDE*1.5);
  
  textSize(20);
  text(1, width/15 - textWidth("1")*2, height/3-AMPLITUDE/2);
  text(0, width/15 - textWidth("0")*2, height/3+AMPLITUDE/2);
  
  fill(BG_COLOR, 255);
  strokeWeight(3);
  circle(width/2, height/2, MIXER_SIZE);
  float mixer_offset = MIXER_SIZE/2 * cos(PI/4);
  line(width/2 - mixer_offset, height/2 - mixer_offset, width/2 + mixer_offset, height/2 + mixer_offset);
  line(width/2 - mixer_offset, height/2 + mixer_offset, width/2 + mixer_offset, height/2 - mixer_offset);
  
  stroke(FRAMEWORK_COLOR);
  if (line_x_finish != line_x_temp_finish) {
    line(line_x_start, height/3, line_x_temp_finish, height/3);
    line(line_x_start, height*2/3, line_x_temp_finish, height*2/3);
  } else {
    line(line_x_start, height/3, line_x_temp_finish, height/3);
    line(line_x_start, height*2/3, line_x_temp_finish, height*2/3);
    line(width/2, line_y_start, width/2, line_y_temp_finish);
    line(width/2, height - line_y_start, width/2, width - line_y_temp_finish);
    line(output_line_x_start, height/2, output_line_x_temp_finish, height/2);
  }
  
  if (draw_triangles){
    fill(FRAMEWORK_COLOR);
    float x_1 = width/2 - TRIANGLE_SIZE/2;
    float y_1 = line_y_temp_finish - TRIANGLE_SIZE;
    float x_2 = width/2 + TRIANGLE_SIZE/2;
    float y_2 = line_y_temp_finish - TRIANGLE_SIZE;
    float x_3 = width/2;
    float y_3 = line_y_temp_finish - 2;
    triangle(x_1, y_1, x_2, y_2, x_3, y_3);
    triangle(x_1, height - y_1, x_2, height - y_2, x_3, height - y_3);
    
    x_1 = output_line_x_temp_finish - TRIANGLE_SIZE;
    y_1 = height/2 + TRIANGLE_SIZE/2;
    x_2 = output_line_x_temp_finish - TRIANGLE_SIZE;
    y_2 = height/2 - TRIANGLE_SIZE/2;
    x_3 = output_line_x_temp_finish;
    y_3 = height/2;
    triangle(x_1, y_1, x_2, y_2, x_3, y_3);
    
  }

} // End of drawFramework()

// ---------- renderSignals() ---------
void renderSignals(int s_opacity) {
  strokeWeight(3); 
  stroke(CARRIER_COLOR, s_opacity);
  
  for (int x = 1; x < yvalues.length; x++) {
    // Carrier Signal
    int x_1 = (x-1) + width/15;
    int x_2 = (x) + width/15;
    float y_1 = height*2/3+yvalues[x-1];
    float y_2 = height*2/3+yvalues[x];
    line(x_1, y_1, x_2, y_2);
    
    
    // Message Signal 
    //int index_2 = (x+theta) % NUM_POINTS;
    //int index_1 = (x+theta - 1) % NUM_POINTS;
    //y_1 = height/3 - digital_signal[index_1]*AMPLITUDE + AMPLITUDE/2;
    //y_2 = height/3 - digital_signal[index_2]*AMPLITUDE + AMPLITUDE/2;
    y_1 = height/3 - message_yvalues[x-1]*1 + AMPLITUDE/2;
    y_2 = height/3 - message_yvalues[x]*1 + AMPLITUDE/2;
    
    line(x_1, y_1, x_2, y_2);


    // Modulated Signal
    x_1 = (x-1) + width - width/15 - WIDTH;
    x_2 = (x) + width - width/15 - WIDTH;
    //y_1 = height/2 + modulated_signal[index_1];
    //y_2 = height/2 + modulated_signal[index_2];
    y_1 = height/2 + am_signal[x-1];
    y_2 = height/2 + am_signal[x];
    
    line(x_1, y_1, x_2, y_2);
  }
} // End of renderSignals()
