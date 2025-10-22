local Shaders = {}

Shaders.flash = love.graphics.newShader([[
#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

extern number u_flash; // 0 = normal, 1 = todo blanco

vec4 effect(vec4 color, Image texture, vec2 texCoord, vec2 screenCoord) {
    vec4 tex = Texel(texture, texCoord) * color;
    
    // Color blanco pero conservando la misma alpha del texel
    vec4 whiteSameA = vec4(1.0, 1.0, 1.0, tex.a);

    // Mezcla lineal hacia blanco manteniendo alpha
    vec4 outc = mix(tex, whiteSameA, clamp(u_flash, 0.0, 1.0));

    return outc;
    }
]])

-- === BLANQUEO PROGRESIVO (mezcla a blanco puro, respetando alpha como máscara) ===
Shaders.whiten = love.graphics.newShader([[
extern number u_white; // 0..1

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
    vec4 c = Texel(tex, tc) * color;
    float a = c.a;
    // mezcla hacia blanco puro ignorando el color original cuando u_white=1.0
    vec3 rgb = mix(c.rgb, vec3(1.0), clamp(u_white, 0.0, 1.0));
    return vec4(rgb, a);
}
]])

-- Rehue simple: fuerza todo a verde manteniendo S y V (evita grises y negros).
Shaders.rehueGreen = love.graphics.newShader([[
extern number u_enabled;

vec3 rgb2hsv(vec3 c){
  float cmax = max(c.r, max(c.g, c.b));
  float cmin = min(c.r, min(c.g, c.b));
  float d = cmax - cmin;
  float h = 0.0;
  if (d > 0.00001) {
    if (cmax == c.r)      h = mod(((c.g - c.b) / d), 6.0);
    else if (cmax == c.g) h = ((c.b - c.r) / d) + 2.0;
    else                  h = ((c.r - c.g) / d) + 4.0;
    h /= 6.0;
    if (h < 0.0) h += 1.0;
  }
  float s = (cmax <= 0.0) ? 0.0 : (d / cmax);
  float v = cmax;
  return vec3(h,s,v);
}

vec3 hsv2rgb(vec3 c){
  float h = c.x * 6.0;
  float s = c.y;
  float v = c.z;
  float i = floor(h);
  float f = h - i;
  float p = v * (1.0 - s);
  float q = v * (1.0 - s * f);
  float t = v * (1.0 - s * (1.0 - f));
  if (i == 0.0) return vec3(v,t,p);
  if (i == 1.0) return vec3(q,v,p);
  if (i == 2.0) return vec3(p,v,t);
  if (i == 3.0) return vec3(p,q,v);
  if (i == 4.0) return vec3(t,p,v);
  return vec3(v,p,q);
}

vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc){
  vec4 px = Texel(tex, tc) * color;
  if (u_enabled < 0.5) return px;

  // Mantén alpha, re-huea a verde (H=0.333) solo si no es casi negro
  vec3 hsv = rgb2hsv(px.rgb);
  if (hsv.z < 0.02) return px;           // evita “brillos” sobre negros
  hsv.x = 0.333;                          // verde puro
  return vec4(hsv2rgb(hsv), px.a);
}
]])

return Shaders