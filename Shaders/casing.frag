#version 150 core

in fData
{
  vec3 normal;
  vec3 position;
  vec4 color;
  float t;
  flat bool applyLight;
} frag;

uniform vec3 GRADIENT_COLOR;
uniform vec3 EYE;
uniform vec3 FORWARD;
uniform mat4 MVP;

#include "math.shader"
#include "phong.shader"
#line 19

out vec4 fragColor;

void main()
{
  vec4 color = vec4(mix(frag.color.rgb, GRADIENT_COLOR, frag.t), frag.color.a);
  if(!frag.applyLight) {
    fragColor = color;
    return;
  }
  fragColor = phongFunction(color.rgb, color.rgb, vec3(1.0), frag.position, frag.normal, FORWARD, 1.0);
}
