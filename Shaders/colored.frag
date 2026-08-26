#version 330 core

in vec3 v_color;

uniform float ALPHA;
// 3. Out variables require explicit precision qualifiers
layout(location = 0) out vec4 o_Color;

void main()
{
    // Use the flattened v_color directly
    o_Color = vec4(v_color, ALPHA);
}