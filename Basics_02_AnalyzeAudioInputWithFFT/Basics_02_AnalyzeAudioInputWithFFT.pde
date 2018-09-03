/**
  * This sketch uses the Minin audio library FFT function to analyze
  * the audio being received from your computers default audio input 
  * and sends the average amplitude of all frequencies as a value
  * from 0-1000 to an Arduino connected via a USB Com port to trigger
  * the Arduino's interal LED based on the volume of incoming sound.
  * <p>
  * FFT stands for Fast Fourier Transform, which is a 
  * method of analyzing audio that allows you to visualize 
  * the frequency content of a signal. You've seen 
  * visualizations like this before in music players 
  * and car stereos.
  * <p>
  * This code was created as a turial for  "Introduction to LED Art",
  * a video series created by Myles de Bastion. 
  * See https://www.patreon.com/mylesdebastion for more information.
  */

import processing.serial.*; // Serial Communication Library (via USB cable to Arduinio)
import ddf.minim.analysis.*;
import ddf.minim.*; // Audio Library

Serial myPort;  // Create object from Serial class
Minim       minim;
AudioInput in;
FFT         fft;

float avgAmplitude; // store avg volume globally 
int avgAmplitudeInt = int(avgAmplitude); // converts the float decimal to a whole integer.

void setup()
{
  size(512, 200, P3D);
  String portName = Serial.list()[0]; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName, 9600);
  
  minim = new Minim(this);
  
  // specify that we want the audio buffers of the AudioPlayer
  // to be 1024 samples long because our FFT needs to have 
  // a power-of-two buffer size and this is a good size.
  // use the getLineIn method of the Minim object to get an AudioInput
  in = minim.getLineIn();
  
  // create an FFT object that has a time-domain buffer 
  // the same size as the audio input sample buffer
  // note that this needs to be a power of two 
  // and that it means the size of the spectrum will be half as large.
  fft = new FFT( in.bufferSize(), in.sampleRate() );
  
}

float maxAmp = 0;
void detectAmplitude()
{
  avgAmplitude = fft.calcAvg(20,20000); // fft.calcAvg(minFreq, maxFreq)
  // maxAmp doesn't decrease, but will ensure values don't
  // exceed 255
  if (avgAmplitude > maxAmp) { maxAmp = avgAmplitude; }
  avgAmplitudeInt = int(avgAmplitude * 1000 / maxAmp);
  myPort.write(avgAmplitudeInt);         // send average amplitude to Arduino
  println(avgAmplitudeInt);              // print average amplitude to console.
}

void draw()
{
  background(0);
  stroke(255);
  
  detectAmplitude();  // Run the detect amplitude function each cycle of the draw loop.
    
  // perform a forward FFT on the samples in LineIn's mix buffer,
  // which contains the mix of both the left and right channels of the file
  fft.forward( in.mix );
  
  for(int i = 0; i < fft.specSize(); i++)
  {
    // draw the line for frequency band i, scaling it up a bit so we can see it
    line( i, height, i, height - fft.getBand(i)*8 );
  }
}


/* Arduino Code to upload to your Microcontroller.
 int ledPin = 13; // Set the pin to digital I/O 13
 char avgAmplitudeInt; // Data received from the serial port

void setup()
{
  pinMode(ledPin, OUTPUT); // Set pin as OUTPUT
  Serial.begin(9600); // Start serial communication at 9600 bps
  Serial.println("<Arduino is ready>");
}

void loop()
{
   if (Serial.available()) 
   { // If data is available to read,
     avgAmplitudeInt = Serial.read(); // read it and store it in val
   }
  digitalWrite(ledPin, HIGH);
  delayMicroseconds(avgAmplitudeInt); // 100 is Approximately 10% duty cycle @ 1KHz
  digitalWrite(ledPin, LOW);
  delayMicroseconds(1000 - 100);
}
*/