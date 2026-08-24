#version 310 es
#extension GL_EXT_geometry_shader : require

layout(lines) in;
layout(triangle_strip, max_vertices = 4) out;

uniform highp float LINE_WIDTH;   
uniform highp vec2 SCREEN_SIZE; 

// 1. Match the exact name and array structure from your new vertex shader
in highp vec3 v_fragPosition[]; 

// 2. Data forwarded to your fragment shader
out highp vec3 f_position;
out highp vec2 v_lineTexCoord;    

void main()
{
    // Extract true homogeneous 3D Clip Space positions directly from gl_in
    highp vec4 p0 = gl_in[0].gl_Position;
    highp vec4 p1 = gl_in[1].gl_Position;

    if (p0.w <= 0.0 && p1.w <= 0.0) return;

    // Safety near-plane clipping
    highp float NEAR_PLANE_W = 0.001;
    if (p0.w < NEAR_PLANE_W) {
        p0 = mix(p0, p1, (NEAR_PLANE_W - p0.w) / (p1.w - p0.w));
    } else if (p1.w < NEAR_PLANE_W) {
        p1 = mix(p1, p0, (NEAR_PLANE_W - p1.w) / (p0.w - p1.w));
    }

    // Transform NDCs into screen pixels
    highp vec2 ndc0 = p0.xy / p0.w;
    highp vec2 ndc1 = p1.xy / p1.w;
    highp vec2 s0 = (ndc0 + 1.0) * 0.5 * SCREEN_SIZE;
    highp vec2 s1 = (ndc1 + 1.0) * 0.5 * SCREEN_SIZE;

    // Calculate line normal vector
    highp vec2 lineDir = s1 - s0;
    highp float len = length(lineDir);
    highp vec2 normal = (len < 0.0001) ? vec2(1.0, 0.0) : vec2(-lineDir.y, lineDir.x) / len;

    // Convert pixel offset back to NDC scale
    highp vec2 ndcOffset = ((normal * (LINE_WIDTH * 0.5)) / SCREEN_SIZE) * 2.0;

    // --- Emit the Quad ---
    
    // Vertex 0: Start Left
    gl_Position = vec4((ndc0 - ndcOffset) * p0.w, p0.z, p0.w);
    v_lineTexCoord = vec2(0.0, 0.0);
    f_position = v_fragPosition[0]; // Forward data from vertex 0
    EmitVertex();

    // Vertex 1: Start Right
    gl_Position = vec4((ndc0 + ndcOffset) * p0.w, p0.z, p0.w);
    v_lineTexCoord = vec2(1.0, 0.0);
    f_position = v_fragPosition[0];
    EmitVertex();

    // Vertex 2: End Left
    gl_Position = vec4((ndc1 - ndcOffset) * p1.w, p1.z, p1.w);
    v_lineTexCoord = vec2(0.0, 1.0);
    f_position = v_fragPosition[1]; // Forward data from vertex 1
    EmitVertex();

    // Vertex 3: End Right
    gl_Position = vec4((ndc1 + ndcOffset) * p1.w, p1.z, p1.w);
    v_lineTexCoord = vec2(1.0, 1.0);
    f_position = v_fragPosition[1];
    EmitVertex();

    EndPrimitive();
}
