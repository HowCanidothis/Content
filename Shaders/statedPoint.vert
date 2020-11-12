#version 400

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in uint vertexState;

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;
uniform float POINT_SIZE;

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
        gl_PointSize = POINT_SIZE;
    }
    vertex.state = vertexState;
    vertex.position = vertexPosition;
    gl_Position = MVP * MODEL_MATRIX * vec4(vertexPosition, 1.0);
}
