import Colour

define WIDTH as 512
define HEIGHT as 512

public void ::draw(int x, int y, Colour c):
    red = Math.round(c.red*255)
    green = Math.round(c.green*255)
    blue = Math.round(c.blue*255)
    draw(x,y,red,green,blue)

public native void ::draw(int x, int y, Int.u8 r, Int.u8 g, Int.u8 b):
