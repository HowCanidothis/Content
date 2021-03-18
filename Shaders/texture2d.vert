#version 450
uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

layout(location = 0) in vec2 a_vertex;
layout(location = 1) in vec2 a_texCoord;


out fData
{
  vec2 position;
  vec2 texCoord;
} frag;

void main()
{
    frag.position = a_vertex;
    frag.texCoord = a_texCoord;
    gl_Position = MVP * MODEL_MATRIX * vec4(a_vertex, 0.0, 1.0);
}