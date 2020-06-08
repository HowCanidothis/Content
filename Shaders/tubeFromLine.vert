#version 150 core

in vec3 vertexPosition;
//in vec3 vertexColor;

out vData
{
    vec3 color;
    vec4 position;
} vertex;

void main()
{
    //vertex.color = vertexColor;
    vertex.position = vec4( vertexPosition, 1.0 );
}
