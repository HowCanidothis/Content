#version 330 core

// Vertex Attributes
layout(location = 0) in vec2 a_vertex;
layout(location = 1) in vec4 a_texLocation;
layout(location = 2) in vec2 a_offsets;
layout(location = 3) in vec4 a_params;
layout(location = 4) in vec2 a_direction;
layout(location = 5) in vec3 a_color;

// Flattened standalone output variables (No interface block for linking safety)
out vec2 v_position;
out vec4 v_texLocation;
out vec2 v_offset;
out vec3 v_color;
flat out int v_index;
out float v_advance;
out float v_totalWidth;
flat out int v_align;
out vec2 v_direction;

void main()
{
    // Assign values cleanly to standalone output streams
    v_texLocation = a_texLocation;
    v_offset      = a_offsets;
    v_position    = a_vertex;
    v_color       = a_color;
    v_index       = int(a_params[0]);
    v_advance     = a_params[1];
    v_totalWidth  = a_params[3]; // Preserved index 3 layout alignment from your original math
    v_direction   = a_direction;
    v_align       = int(a_params[2]); // Preserved index 2 layout alignment from your original math

    // Explicit pass-through assignment for primitive assembly initialization
    gl_Position = vec4(a_vertex, 0.0, 1.0);
}
