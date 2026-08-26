#version 330 core

// 1. Matrices and View Calculations with qualifiers
uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

// 2. Vertex Attributes matching your C++ layout
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;

// 3. Flattened standalone output variables (No interface block)
out vec3 v_fragNormal;
out vec3 v_fragPosition;

void main()
{
    // Calculate world positions and normals using standalone attributes
    v_fragPosition = (MODEL_MATRIX * vec4(a_vertex, 1.0)).xyz;
    v_fragNormal = normalize((MODEL_MATRIX * vec4(a_vertexNormal, 0.0)).xyz);

    // Output final screen space projection position
    gl_Position = MVP * MODEL_MATRIX * vec4(a_vertex, 1.0);
}
