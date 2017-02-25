varying lowp vec4 DestinationColor;

varying lowp vec2 TextureCoordinateOut;
uniform sampler2D Texture;

void main(void) {
    gl_FragColor = DestinationColor * texture2D(Texture, TextureCoordinateOut);
}
