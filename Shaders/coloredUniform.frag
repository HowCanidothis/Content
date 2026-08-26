#version 330 core

// 2. Uniform declarations require explicit precision precision qualifiers
uniform vec4 COLOR;

// 3. Out variables require explicit precision qualifiers
out vec4 o_Color;

void main()
{
    o_Color = COLOR;
}
