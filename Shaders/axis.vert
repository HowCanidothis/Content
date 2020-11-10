#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;

uniform float OFFSET_UNITS;

void main()
{
    vec4 position = MVP * vec4(a_vertex, 1.0);
    position.w += OFFSET_UNITS;
    gl_Position = position;
}