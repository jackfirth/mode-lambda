#version 330

uniform sampler2D LayerTargets[@LAYERS];
uniform sampler2D LayerConfigTex;
uniform uint ViewportWidth;
uniform uint ViewportHeight;

in vec2 texCoord;

out vec4 oFragColor;

float jmod(float a, float n) {
  return a - (n * floor(a / n));
}

float wrap(float v, float c, float hrng) {
  if (isinf(hrng)) {
    return v;
  } else {
    return (c + ((jmod(v, (2.0 * hrng))) - hrng));
  }
}

float compute_pz(float mode7coeff, float ay_horiz) {
  // xxx make lagrange rather than cond (to match software and be weird)
  
  if (mode7coeff == 0.0) { return 1.0; }
  if (mode7coeff == 1.0) { return +1.0 * ay_horiz; }
  if (mode7coeff == 2.0) { return -1.0 * ay_horiz; }
  if (mode7coeff == 3.0) { return abs(ay_horiz); }
  return 0.0;
}

float compute_e(float ax, float hwidth, float fov, float pz, float Lcx, float Lhw) {
  float rx = ((ax - hwidth) * (fov / pz)) + hwidth;
  if (isinf(rx) || isnan(rx)) {
    return -1.0;
  } else {
    float wx = wrap(rx, Lcx, Lhw);
    float ix = round(wx);
    return ix;
  }
}

void main() {
  float hwidth = float(ViewportWidth) / 2.0;
  float hheight = float(ViewportHeight) / 2.0;
  
  vec4 fin_Color = vec4(0.0, 0.0, 0.0, 1.0);
  float ax = texCoord.x * ViewportWidth;
  // xxx this is wrong because in OpenGL the top is 1 not 0
  float ay = texCoord.y * ViewportHeight;

  for (int layer = 0 ; layer < @LAYERS ; layer++) {
    @glsl-include["layer.glsl"]
    float ay_horiz = horizon - ay;
    float pz = compute_pz(mode7coeff, ay_horiz);
    float ex = compute_e(ax, hwidth, fov, pz, Lcx, Lhw);
    float ey = compute_e(ay, hheight, fov, pz, Lcy, Lhh);
    vec4 lay_Color = texture(LayerTargets[layer],
                             vec2(ax / ViewportWidth,
                                  ay / ViewportHeight));
    fin_Color.rgb = fin_Color.rgb * (1.0 - lay_Color.a) + lay_Color.rgb * lay_Color.a;
  }
  
  oFragColor = fin_Color;
}