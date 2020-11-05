#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;

uniform mat4 MODEL_MATRIX;

out fData
{
  vec3 normal;
  vec3 position;
} frag;

void main()
{
    frag.position = (MODEL_MATRIX * vec4(a_vertex, 1.0)).xyz;
    frag.normal = normalize((MODEL_MATRIX * vec4(a_vertexNormal, 0.0)).xyz);
    gl_Position = MVP * MODEL_MATRIX * vec4(a_vertex, 1.0);
}