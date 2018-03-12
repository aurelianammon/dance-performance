import org.openkinect.processing.*;

Kinect2 kinect;

int lowerThreshold = 1000;
int upperThreshold = 4500;

PImage output;
int totalPixels;

int[] depthMap;

color[] previousPixels;

void setup() {
    // size(512, 424);
    fullScreen();
    kinect = new Kinect2(this);
    kinect.initDepth();
    kinect.initDevice();

    output = new PImage(512, 424);
    background(0);

    totalPixels = kinect.depthWidth*kinect.depthHeight;

    loadPixels();
    previousPixels = new color[totalPixels];

    // frameRate(25);
}

void draw() {

    PImage img = kinect.getDepthImage();
    depthMap = kinect.getRawDepth();

    output.loadPixels();

    for (int x = 0; x < kinect.depthWidth; x++) {
        for (int y = 0; y < kinect.depthHeight; y++) {
            int loc = x + y * kinect.depthWidth;
            int rawDepth = depthMap[loc];
            
            if (rawDepth > lowerThreshold && rawDepth < upperThreshold) {

                pixelAdd(loc, 15);

            } else {

                if (frameCount%3 == 0 && true) {

                    int[] neighbours = pixelsAround(loc);
                    for (int i = 0; i < neighbours.length; i++) {
                        if (previousPixels[loc] < previousPixels[neighbours[i]]) {

                            output.pixels[neighbours[i]] = previousPixels[loc];
                            // pixelAdd(neighbours[i]);
                        }
                    }
                }
                
                if (frameCount%1 == 0) {

                    pixelAdd(loc, -1);
                }
            }
        }
    }

    arrayCopy(output.pixels, previousPixels);

    output.updatePixels();

    image(output,150,-100,width-300,height+200);
    // println(frameRate);
}

//function to subtract or add values from the color of a pixel
void pixelAdd(int index, int value) {

    //create components for new color
    float green = green(output.pixels[index])+value;
    float red = red(output.pixels[index])+value;
    float blue = blue(output.pixels[index])+value;

    //combine color values
    color newColor =  color(green, red, blue);

    //write color to the current pixel
    output.pixels[index] = newColor;
}

//function to find neightbours of a pixel
int[] pixelsAround(int index) {

    int[] values = new int[4];

    values[0] = (index - 1);
    if (values[0] < 0) {
        values[0] = totalPixels - 1 + values[0];
    }
    values[1] = (index + 1) % (totalPixels - 1);
    values[2] = (index - kinect.depthWidth);
    if (values[2] < 0) {
        values[2] = totalPixels - 1 + values[2];
    }
    values[3] = (index + kinect.depthWidth) % (totalPixels - 1);

    return values;
}