#version 450
uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

layout(location = 0) in vec3 a_vertex;


out fData
{
  vec3 position;
} frag;

void main()
{
    frag.position = a_vertex;
    gl_Position = MVP * MODEL_MATRIX * vec4(a_vertex, 1.0);
}