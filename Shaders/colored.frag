#version 450
in vec3 v_color;
layout(location = 0) out vec4 o_Color;

void main()
{
    o_Color = vec4(v_color, 1.0);
}