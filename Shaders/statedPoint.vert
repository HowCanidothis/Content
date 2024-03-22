#version 400

layout(location = 0) in vec3 vertexPosition;
layout(location = 1) in uint vertexState;
layout(location = 2) in uint vertexTransparency;

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;
uniform float POINT_SIZE;

out vData
{
    flat uint state;
    flat uint transparency;
} vertex;

void main()
{
    float ps;
    if((vertexState & 7u) != 0u) {
        ps = POINT_SIZE * 3.0;
    } else {
        ps = POINT_SIZE;
    }
    gl_PointSize = ps;
    vertex.state = vertexState;
    vertex.transparency = vertexTransparency;
    gl_Position = MVP * MODEL_MATRIX * vec4(vertexPosition, 1.0);
}
