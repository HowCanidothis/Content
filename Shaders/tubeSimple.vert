#version 450

layout (location = 0) in vec3 vertexPosition;
layout (location = 2) in uint transparency;

out vData
{
    vec3 position;
    flat uint transparency;
} vertex;

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

void main()
{
    vertex.position = vertexPosition;
    vertex.transparency = transparency;
    gl_Position = MVP * MODEL_MATRIX * vec4(vertexPosition, 1.0);
}
