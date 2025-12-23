#version 450

in fData
{
  vec3 normal;
  vec3 position;
} frag;

uniform vec4 COLOR;
uniform vec3 FORWARD;

out vec4 fragColor;

#line 0
#include "fakeLight.shader"

void main()
{
    fragColor = phongFunction(COLOR.rgb, COLOR.rgb, vec3(1.0), frag.position, frag.normal, vec3(0.0,0.0,-1.0), COLOR.a);
}
