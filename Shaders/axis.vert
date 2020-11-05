#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;

void main()
{
    gl_Position = MVP * vec4(a_vertex, 1.0);
}