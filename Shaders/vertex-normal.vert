#version 450

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

// Vertex Attributes - Order must perfectly match your C++ VBO packing
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;

out fData
{
    vec3 normal;
    vec3 position;
} frag;

void main()
{
    // Calculate world positions and normals
    frag.position = (MODEL_MATRIX * vec4(a_vertex, 1.0)).xyz;
    frag.normal = normalize((MODEL_MATRIX * vec4(a_vertexNormal, 0.0)).xyz);

    // Output final screen space projection position
    gl_Position = MVP * MODEL_MATRIX * vec4(a_vertex, 1.0);
}