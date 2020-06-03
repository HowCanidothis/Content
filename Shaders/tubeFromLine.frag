#version 150 core

in vec3 worldPosition;
in vec3 worldNormal;


uniform vec3 maincolor;
uniform vec3 eyePosition;

out vec4 fragColor;

#pragma include phong.inc.frag

void main()
{
    // vec3 worldView = normalize(eyePosition - worldPosition);
    fragColor = vec4(maincolor, 1.0);
}
