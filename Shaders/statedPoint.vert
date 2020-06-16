#version 450 core

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in uint vertexState;

uniform mat4 MVP;

out vData
{
    flat uint state;
    vec3 position;
} vertex;

void main()
{
    if(vertexState == 1u) {
        gl_PointSize = 20.0;
    } else {
        gl_PointSize = 10.0;
    }
    vertex.state = vertexState;
    vertex.position = vertexPosition;
    gl_Position = MVP * vec4(vertexPosition, 1.0);
}
