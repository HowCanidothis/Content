#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec2 a_texCoord;

void main()
{
    gl_Position = MVP * vec4(vec3(a_vertex.xy, -100.0), 1.0);
}