#version 450
layout(location = 0) in vec2 a_vertex;
layout(location = 1) in vec2 a_texC;

void main()
{
    gl_Position = vec4(a_vertex, 0.0, 1.0);
}