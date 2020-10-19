#version 450

uniform vec4 COLOR;
uniform vec3 EYE_POSITION;

in vData
{
    vec3 position;
} vertex;

out vec4 fragColor;

void main()
{
    fragColor = COLOR;
}
