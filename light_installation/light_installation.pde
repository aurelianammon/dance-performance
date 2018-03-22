import org.openkinect.processing.*;

Kinect2 kinect;

int lowerThreshold = 1000;
int upperThreshold = 4500;

PImage output;
int totalPixels;

int[] depthMap;

color[] previousPixels;

boolean on_pause = false;

//mapping settings
int left = 50;
int right = 10;
int top = 70;
int bottom = 70;

void setup() {

    // size(512, 424);
    fullScreen(P2D);

    //initialize kinect class and device
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

                if (!on_pause) {
                    pixelAdd(loc, 15);
                }

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

    PImage croped = output.get(left, top, kinect.depthWidth - left - right, kinect.depthHeight - top - bottom);

    //scale output image to the screen size 
    image(croped, 0, 0, width, height);

    println(frameRate);
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

// start and stop with spacebar
void keyPressed() {

    if (keyCode == 32) {
        on_pause = !on_pause;
    }
}
