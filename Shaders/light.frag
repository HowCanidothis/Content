#version 450

in fData
{
  vec3 normal;
  vec3 position;
} frag;

uniform vec4 COLOR;
uniform vec3 FORWARD;
uniform vec3 EYE;

out vec4 fragColor;

#include "phong.shader"

void main()
{
    fragColor = phongFunction(COLOR.rgb, COLOR.rgb, vec3(1.0), frag.position, frag.normal, FORWARD, COLOR.a);
}
