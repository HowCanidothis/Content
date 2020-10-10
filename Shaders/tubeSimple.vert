#version 150 core

in vec3 vertexPosition;

uniform mat4 MVP;
uniform mat4 modelMatrix;

out vData
{
    vec3 position;
} vertex;

void main()
{
    vertex.position = vertexPosition;
    gl_Position = MVP * modelMatrix * vec4(vertexPosition, 1.0);
}
