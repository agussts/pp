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

Shaders.allWhite = love.graphics.newShader([[
extern float thresh;
vec4 effect(vec4 color, Image tex, vec2 tc, vec2 sc) {
  vec4 px = Texel(tex, tc);
  if (px.a <= thresh) return vec4(0.0);
  return vec4(1.0, 1.0, 1.0, px.a);
}
]])

return Shaders