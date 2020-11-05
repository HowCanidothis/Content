#version 150 core

in fData
{
  vec3 normal;
  vec3 position;
} frag;

uniform vec4 COLOR;
uniform vec3 EYE;
uniform vec3 FORWARD;
uniform mat4 MVP;
const float SCALE = 0.1;

out vec4 fragColor;

#include "phong.shader"

void main()
{
    vec3 worldView = EYE - frag.position;
    float distanceToFragment = length(worldView);

    if(distanceToFragment > 5000.0) {
        discard;
    } else if(gl_FrontFacing) {
        if(distanceToFragment > 50.0) {
            fragColor = phongFunction(vec3(0.0), COLOR.rgb, vec3(1.0), 1.0, frag.position, frag.normal, FORWARD);
        } else {
            discard;
        }
    } else if(distanceToFragment < 1000.0) {
        fragColor = phongFunction(vec3(0.0), COLOR.rgb, vec3(1.0), 1.0, frag.position, frag.normal, -FORWARD);
    } else {
        discard;
    }
}
