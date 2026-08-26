#version 330 core

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;
layout(location = 2) in mat4 a_transform;      

out vec3 v_fragNormal;
out vec3 v_fragPosition;

void main()
{
    mat4 finalModelMatrix = MODEL_MATRIX * a_transform;

    v_fragPosition = (finalModelMatrix * vec4(a_vertex, 1.0)).xyz;
    v_fragNormal = normalize((finalModelMatrix * vec4(a_vertexNormal, 0.0)).xyz);

    gl_Position = MVP * finalModelMatrix * vec4(a_vertex, 1.0);
}
