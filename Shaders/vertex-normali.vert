#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;
layout(location = 2) in mat4 a_transform;

uniform mat4 MODEL_MATRIX;

out fData
{
  vec3 normal;
  vec3 position;
} frag;

void main()
{
    // Combined Transform Matrix: Global Model Uniform * Local Per-Instance Data
    mat4 finalModelMatrix = MODEL_MATRIX * a_transform;

    frag.position = (finalModelMatrix * vec4(a_vertex, 1.0)).xyz;
    frag.normal = normalize((finalModelMatrix * vec4(a_vertexNormal, 0.0)).xyz);
    gl_Position = MVP * finalModelMatrix * vec4(a_vertex, 1.0);
}
