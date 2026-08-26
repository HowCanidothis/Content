#version 330 core

// 1. Explicit input locations
layout(location = 0) in vec3 a_vertex;

uniform vec2 SCREEN_SIZE;

// 2. Flattened standalone output variables (No interface block)
out vec2 v_position;

void main()
{
    // Y-axis flip calculation for screen coordinates
    v_position = vec2(a_vertex.x, SCREEN_SIZE.y - a_vertex.y);
    
    // Convert screen coordinates into Normalized Device Coordinates (-1.0 to 1.0)
    vec2 halfScreenSize = SCREEN_SIZE / 2.0;
    gl_Position = vec4((v_position - halfScreenSize) / halfScreenSize, 0.0, 1.0);
}
