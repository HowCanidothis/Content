#version 450

in fData
{
  vec3 color;
} frag;

layout(location = 0) out vec4 o_Color;

void main()
{
    o_Color = vec4(frag.color, 1.0);
}