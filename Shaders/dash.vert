#version 400

layout (location = 0) in vec3 inPos;
layout (location = 2) in uint transparency;

out vData
{
    vec3 vertPos;
    flat vec3 startPos;
    flat uint transparency;
} vertex;

uniform mat4 MVP;

void main()
{
    vec4 pos    = MVP * vec4(inPos, 1.0);
    gl_Position = pos;
    vertex.vertPos     = pos.xyz / pos.w;
    vertex.startPos    = vertex.vertPos;
    vertex.transparency = transparency;
}