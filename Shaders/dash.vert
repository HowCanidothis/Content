#version 400

layout (location = 0) in vec3 inPos;
layout (location = 2) in uint transparency;

out vData
{
    float dist;
    flat uint transparency;
} vertex;

uniform mat4 MVP;

void main()
{
    vertex.dist = inPos.z;
    vec4 pos    = MVP * vec4(vec3(inPos.xy, 0.0), 1.0);
    gl_Position = pos;
    vertex.transparency = transparency;
}