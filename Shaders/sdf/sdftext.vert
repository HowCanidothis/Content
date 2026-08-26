#version 330 core

uniform mat4 MODEL_MATRIX;

layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec4 a_texLocation;
layout(location = 2) in vec2 a_offsets;
layout(location = 3) in vec4 a_params;
layout(location = 4) in vec3 a_direction;
layout(location = 5) in vec4 a_offsetDirection;

out vec3 v_position;
out vec4 v_texLocation;
out vec2 v_offset;
flat out int v_index;
out float v_advance;
out float v_totalWidth;
flat out int v_align;
out vec3 v_direction;
out vec4 v_offsetDirection;

void main()
{
    vec4 transformedPosition = (MODEL_MATRIX * vec4(a_vertex, 1.0));
    transformedPosition /= transformedPosition.w;
    
    v_texLocation = a_texLocation;
    v_offset = a_offsets;
    v_position = transformedPosition.xyz;
    
    v_index = int(a_params[0]);
    v_advance = a_params[1];
    v_totalWidth = a_params[2];
    v_align = int(a_params[3]);
    
    v_direction = (MODEL_MATRIX * vec4(a_direction, 0.0)).xyz;
    
    float w = a_offsetDirection.w;
    v_offsetDirection = vec4((MODEL_MATRIX * vec4(a_offsetDirection.xyz, 0.0)).xyz, w);
}
