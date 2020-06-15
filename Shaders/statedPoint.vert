#version 150 core

in vec3 vertexPosition;
in uint vertexState;

uniform mat4 MVP;

out vData
{
    uint state;
    vec3 position;
} vertex;

void main()
{
    if(vertexState == 1u) {
        gl_PointSize = 40.f;
    } else {
        gl_PointSize = 20.f;
    }
    vertex.position = vertexPosition;
    gl_Position = MVP * vec4(vertexPosition, 1.0);
}
