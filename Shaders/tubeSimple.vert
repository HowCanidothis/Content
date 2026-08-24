#version 310 es

#undef lowp
#undef mediump
#undef highp

layout(location = 0) in highp vec3 vertexPosition;
layout(location = 2) in uint transparency;

flat out uint vs_transparency;

void main()
{
    vs_transparency = transparency & 0xFFu;
    gl_Position = vec4(vertexPosition, 1.0);
}
