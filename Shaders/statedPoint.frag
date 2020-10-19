#version 400

uniform vec4 COLOR;
uniform vec3 EYE_POSITION;

in vData
{
    flat uint state;
    vec3 position;
} vertex;

out vec4 fragColor;

void main()
{
    fragColor = COLOR;
}
