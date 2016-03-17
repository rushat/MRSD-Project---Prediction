import processing.serial.*;
Serial mySerial;

PrintWriter output;  
String[] list;

void setup() {
    //size(500,500);
    //background(255);
    mySerial = new Serial( this, "COM4",250000 );
    output = createWriter("myTextFile.txt");
}
void draw() {
  if (mySerial.available() > 0 ) {
     String value = mySerial.readString();
     String[] valueArray = split(value, ' ');
     println(value);
     output.println(value);
     saveStrings("myTextFile.txt", valueArray);
  } 
}

void keyPressed() {
output.flush(); // Writes the remaining data to the file
output.close(); // Finishes the file
exit(); // Stops the program
}