#version 450

uniform vec4 COLOR;
uniform vec3 EYE_POSITION;

in vData
{
    vec3 position;
    flat uint transparency;
} vertex;

out vec4 fragColor;

void main()
{
    fragColor = vec4(COLOR.rgb, vertex.transparency / 255.0);
}
