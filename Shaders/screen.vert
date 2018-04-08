#version 450
layout(location = 0) in vec2 a_vertex;
layout(location = 1) in vec2 a_texCoords;
out vec2 v_texCoords;

void main()
{
    gl_Position = vec4(a_vertex, 0.0, 1.0);
    v_texCoords = a_texCoords;
}