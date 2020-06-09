#version 450

uniform vec4 COLOR;
uniform vec3 eyeposition;

in vData
{
    vec3 color;
    vec3 position;
} vertex;

out vec4 fragColor;

void main()
{
    vec3 worldView = eyeposition - vertex.position;
    if(length(worldView) > 2000.0) {
        fragColor = COLOR;
    } else {
        discard;
    }
}