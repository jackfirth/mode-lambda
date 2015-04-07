#version 330

uniform sampler2D SpriteAtlasTex; 
uniform sampler2D PaletteAtlasTex;

// None of these are "flat" because they are the same on all vertices
// anyways, except TexCoord which needs to be interpolated across the
// triangle.
in vec4 Color;
in vec2 TexCoord;
in float Palette;
in float Layer;

@in[i (in-range LAYERS)]{
  layout (location = @i) out vec4 out_Color@i;
}

float clampx ( float v ) { return floor(v) + 0.5; }
float clampy ( float v ) { return floor(v) - 0.5; }
 
void main(void)
{
  vec4 PixelColor;
  
  ivec2 TexCoord_uv = ivec2(clampx(TexCoord.x), clampy(TexCoord.y));
  vec4 SpriteColor = texelFetch(SpriteAtlasTex, TexCoord_uv, 0);

  if ( Palette == 0.0 ) {
    PixelColor = SpriteColor;
  } else {
    float PaletteOffset = SpriteColor.g * 255;
    ivec2 PalCoord_uv = ivec2( PaletteOffset, Palette );
    PixelColor = texelFetch(PaletteAtlasTex, PalCoord_uv, 0 );
  }

  vec4 fin_Color;
  
  fin_Color.a = PixelColor.a * Color.a;
  fin_Color.rgb = PixelColor.rgb + Color.rgb;

  vec4 blank_Color = vec4(0.0,0.0,0.0,0.0);
  
  int iLayer = int(floor(Layer));
  @in[i (in-range LAYERS)]{
    if (iLayer == @i) { out_Color@i = fin_Color; }
    else { out_Color@i = blank_Color; }
  }
}
