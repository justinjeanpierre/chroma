attribute vec4 Position;
attribute vec4 SourceColor;

varying vec4 DestinationColor;

uniform mat4 Projection; //  for depth
uniform mat4 Modelview;

attribute vec2 TextureCoordinateIn; // for texture
varying vec2 TextureCoordinateOut;  // for texture

void main(void) {
    DestinationColor = SourceColor;
    gl_Position = Projection * Modelview * Position;
    TextureCoordinateOut = TextureCoordinateIn; // for texture
}
