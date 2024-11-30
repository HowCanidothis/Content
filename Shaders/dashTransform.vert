#version 400

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

layout (location = 0) in vec3 inPos;

out vData
{
    float dist;
    flat uint transparency;
} vertex;

void main()
{
    vertex.dist = abs(inPos.x) + abs(inPos.y);
    vec4 pos    = MVP * MODEL_MATRIX * vec4(vec3(inPos.xy, 0.0), 1.0);
    gl_Position = pos;
    vertex.transparency = 255;
}