#version 330 core

in vec3 v_fragNormal;
in vec3 v_fragPosition;

uniform vec4 COLOR;
uniform vec3 EYE;
uniform vec3 FORWARD;
uniform mat4 MVP;

layout(location = 0) out vec4 fragColor;

#include "phong.shader"

void main()
{
    vec3 worldView = EYE - v_fragPosition;
    float distanceToFragment = length(worldView);

    if(distanceToFragment > 5000.0) {
        discard;
    } else if(gl_FrontFacing) {
        if(distanceToFragment > 50.0) {
            fragColor = phongFunction(COLOR.rgb, COLOR.rgb, vec3(0.0), v_fragPosition, v_fragNormal, FORWARD, COLOR.a);
        } else {
            discard;
        }
    } else if(distanceToFragment < 1000.0) {
        fragColor = phongFunction(COLOR.rgb / 2.0, COLOR.rgb, vec3(0.0), v_fragPosition, v_fragNormal, -FORWARD, COLOR.a);
    } else {
        discard;
    }
}
