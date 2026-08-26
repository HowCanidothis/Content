#version 330 core

layout(lines) in;
layout(triangle_strip, max_vertices = 4) out;

uniform vec2 SCREEN_SIZE; 
uniform float LINE_WIDTH;   

in vec2 v_position[]; // Raw screen position from vertex shader

out vec2 v_screenDir;    

void main()
{
    // 1. Get the screen positions directly (no W-divide needed for 2D)
    vec2 s0 = v_position[0];
    vec2 s1 = v_position[1];

    // 2. Calculate line direction and its 90-degree perpendicular normal
    vec2 lineDir = s1 - s0;
    if (length(lineDir) < 0.0001) {
        lineDir = vec2(1.0, 0.0);
    }
    
    vec2 normalizedDir = normalize(lineDir);
    vec2 normal = vec2(-normalizedDir.y, normalizedDir.x);

    // 3. Compute pixel offset and convert straight to NDC scale
    vec2 screenSpaceOffset = normal * (LINE_WIDTH * 0.5);
    vec2 ndcOffset = (screenSpaceOffset / SCREEN_SIZE) * 2.0;

    // 4. Output the 4 quad corners cleanly
    vec4 clip0 = gl_in[0].gl_Position;
    vec4 clip1 = gl_in[1].gl_Position;

    // Vertex 0: Start Left
    gl_Position = vec4(clip0.xy - ndcOffset, 0.0, 1.0);
    v_screenDir = normalizedDir;
    EmitVertex();

    // Vertex 1: Start Right
    gl_Position = vec4(clip0.xy + ndcOffset, 0.0, 1.0);
    v_screenDir = normalizedDir;
    EmitVertex();

    // Vertex 2: End Left
    gl_Position = vec4(clip1.xy - ndcOffset, 0.0, 1.0);
    v_screenDir = normalizedDir;
    EmitVertex();

    // Vertex 3: End Right
    gl_Position = vec4(clip1.xy + ndcOffset, 0.0, 1.0);
    v_screenDir = normalizedDir;
    EmitVertex();
    
    EndPrimitive();
}
