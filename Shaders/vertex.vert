#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;

out fData
{
  vec3 position;
} frag;

void main()
{
    frag.position = a_vertex;
    gl_Position = MVP * vec4(a_vertex, 1.0);
}