#version 450

layout(location = 0) out float o_Color;

void main()
{
    o_Color = gl_FragCoord.z;
}