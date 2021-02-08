#version 450

in fData
{
  vec3 normal;
  vec3 position;
} frag;

uniform vec4 COLOR;
uniform vec3 FORWARD;

out vec4 fragColor;

#include "fakeLight.shader"

void main()
{
    fragColor = phongFunction(vec3(0.1), COLOR.rgb, vec3(1.0), 2.0, frag.position, frag.normal, FORWARD);
}
