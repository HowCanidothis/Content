#version 450
uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_color;

out fData
{
  vec3 color;
} frag;

void main()
{
    frag.color = a_color;
    gl_Position = MVP * MODEL_MATRIX * vec4(a_vertex, 1.0);
}