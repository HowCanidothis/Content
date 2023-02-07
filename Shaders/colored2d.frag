#version 450

in fData
{
    vec2 position;
    vec3 color;
} frag;

uniform float ALPHA = 1.0;
layout(location = 0) out vec4 o_Color;

void main()
{
    o_Color = vec4(frag.color, ALPHA);
}