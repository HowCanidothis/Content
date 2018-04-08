#version 450
uniform mat4 MVP;
uniform float zValue = 0.0;
layout(location = 0) in vec2 a_vertex;
layout(location = 1) in vec3 a_color;
out vec3 v_color;

void main()
{
    gl_Position = MVP * vec4(a_vertex, zValue, 1.0);
    v_color = a_color;
}