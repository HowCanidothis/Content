#version 330 core

layout(location = 0) out float o_Color;

void main()
{
    o_Color = gl_FragCoord.z;
}