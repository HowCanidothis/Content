#version 150 core

in vec3 vertexPosition;

out vData
{
    vec4 position;
} vertex;

void main()
{
    vertex.position = vec4( vertexPosition, 1.0 );
}
