#version 330 core

layout(location = 0) in vec3 a_vertex;
layout(location = 1) in uint a_vertexState;
layout(location = 2) in uint a_vertexTransparency;

uniform mat4 MVP; 
uniform mat4 MODEL_MATRIX;

flat out uint vs_state;
flat out uint vs_transparency;

void main()
{
    vs_state = a_vertexState & 0xFFu;
    vs_transparency = a_vertexTransparency & 0xFFu;
    
    vec4 point = MVP * MODEL_MATRIX * vec4(a_vertex, 1.0);
    gl_Position = point;
}
