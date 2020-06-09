#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;
in vec3 a_vertexNormal;

uniform mat4 invertedMVP;

out fData
{
  flat vec3 normal;
  vec3 position;
} frag;

void main()
{
    frag.position = a_vertex;
    frag.normal = -a_vertexNormal; // vec3(invertedMVP * vec4(a_vertexNormal, 0.0));
    gl_Position = MVP * vec4(a_vertex, 1.0);
}