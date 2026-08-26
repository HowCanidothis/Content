#version 330 core

layout(lines) in;
layout(triangle_strip, max_vertices = 4) out;

uniform float LINE_WIDTH;   
uniform vec2 SCREEN_SIZE; 

// Pass the screen positions and normalized direction to the fragment shader
flat out vec2 v_screenDir;

void main()
{
    vec4 p0 = gl_in[0].gl_Position;
    vec4 p1 = gl_in[1].gl_Position;

    if (p0.w <= 0.0 && p1.w <= 0.0) return;

    if (p0.w <= 0.0) {
        float t = (0.001 - p0.w) / (p1.w - p0.w);
        p0 = mix(p0, p1, t);
    } else if (p1.w <= 0.0) {
        float t = (0.001 - p1.w) / (p0.w - p1.w);
        p1 = mix(p1, p0, t);
    }

    vec2 ndc0 = p0.xy / p0.w;
    vec2 ndc1 = p1.xy / p1.w;

    vec2 s0 = (ndc0 + 1.0) * 0.5 * SCREEN_SIZE;
    vec2 s1 = (ndc1 + 1.0) * 0.5 * SCREEN_SIZE;

    vec2 lineDir = s1 - s0;
    if (length(lineDir) < 0.0001) {
        lineDir = vec2(1.0, 0.0);
    }
    vec2 normalizedDir = normalize(lineDir);
    vec2 normal = vec2(-normalizedDir.y, normalizedDir.x);

    vec2 screenSpaceOffset = normal * (LINE_WIDTH * 0.5);
    vec2 ndcOffset = (screenSpaceOffset / SCREEN_SIZE) * 2.0;

    // Vertex 0
    gl_Position = vec4((ndc0 - ndcOffset) * p0.w, p0.z, p0.w);
    v_screenDir = normalizedDir; // Set right before emit
    EmitVertex();

    // Vertex 1
    gl_Position = vec4((ndc0 + ndcOffset) * p0.w, p0.z, p0.w);
    v_screenDir = normalizedDir; 
    EmitVertex();

    // Vertex 2
    gl_Position = vec4((ndc1 - ndcOffset) * p1.w, p1.z, p1.w);
    v_screenDir = normalizedDir; 
    EmitVertex();

    // Vertex 3
    gl_Position = vec4((ndc1 + ndcOffset) * p1.w, p1.z, p1.w);
    v_screenDir = normalizedDir; 
    EmitVertex();


    EndPrimitive();
}
