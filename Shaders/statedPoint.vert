#version 310 es

#undef lowp
#undef mediump
#undef highp

layout(location = 0) in highp vec3 vertexPosition;
layout(location = 1) in uint vertexState;
layout(location = 2) in uint vertexTransparency;

flat out uint vs_state;
flat out uint vs_transparency;

void main()
{
    vs_state = vertexState & 0xFFu;
    vs_transparency = vertexTransparency & 0xFFu;
    
    // Pass raw model-space position down to the geometry shader
    gl_Position = vec4(vertexPosition, 1.0);
}
