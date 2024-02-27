#version 330

layout (location = 0) in vec3 inPos;

flat out vec3 startPos;
out vec3 vertPos;

uniform mat4 MVP;

void main()
{
    vec4 pos    = MVP * vec4(inPos, 1.0);
    gl_Position = pos;
    vertPos     = pos.xyz / pos.w;
    startPos    = vertPos;
}