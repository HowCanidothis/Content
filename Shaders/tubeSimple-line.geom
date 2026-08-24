#version 310 es

#extension GL_OES_geometry_shader : require

#undef lowp
#undef mediump
#undef highp

layout(lines) in;
layout(triangle_strip, max_vertices = 4) out;

uniform highp mat4 MVP;
uniform highp mat4 MODEL_MATRIX;
uniform highp float LINE_WIDTH;   
uniform highp vec2 SCREEN_SIZE; 

flat in uint vs_transparency[];

flat out uint v_transparency;
out highp vec2 v_lineTexCoord;    

void main()
{
    // 1. Project 3D vertices into true homogeneous 3D Clip Space
    highp vec4 p0 = MVP * MODEL_MATRIX * gl_in[0].gl_Position;
    highp vec4 p1 = MVP * MODEL_MATRIX * gl_in[1].gl_Position;

    // Early out if the entire segment is completely behind the camera lens
    if (p0.w <= 0.0 && p1.w <= 0.0) {
        return;
    }

    // 2. Perform safety near-plane clipping adjustments
    if (p0.w <= 0.0) {
        highp float t = (0.001 - p0.w) / (p1.w - p0.w);
        p0 = mix(p0, p1, t);
    } else if (p1.w <= 0.0) {
        highp float t = (0.001 - p1.w) / (p0.w - p1.w);
        p1 = mix(p1, p0, t);
    }

    // 3. Extract standard 2D Normalized Device Coordinates (NDC)
    highp vec2 ndc0 = p0.xy / p0.w;
    highp vec2 ndc1 = p1.xy / p1.w;

    // 4. Transform NDCs into actual screen pixel positions
    highp vec2 s0 = (ndc0 + 1.0) * 0.5 * SCREEN_SIZE;
    highp vec2 s1 = (ndc1 + 1.0) * 0.5 * SCREEN_SIZE;

    // 5. Calculate the 2D pixel normal perpendicular direction
    highp vec2 lineDir = s1 - s0;
    if (length(lineDir) < 0.0001) {
        lineDir = vec2(1.0, 0.0);
    }
    highp vec2 normal = normalize(vec2(-lineDir.y, lineDir.x));

    // Calculate the exact screen pixel offset vector
    highp vec2 screenSpaceOffset = normal * (LINE_WIDTH * 0.5);

    // Convert the pixel offset into standard NDC coordinates (-1.0 to 1.0 scale)
    highp vec2 ndcOffset = (screenSpaceOffset / SCREEN_SIZE) * 2.0;

    v_transparency = vs_transparency[0];

    // 6. OUTPUT PERSPECTIVE-CORRECTED 2D SCREEN QUAD
    // By multiplying the ndcOffset by the respective vertex's original W factor, 
    // we keep the offset constant in screen pixels while preserving the true 3D 
    // perspective depth attributes across the face of the generated ribbon.

    // Vertex 0: Start Point - Left Offset
    gl_Position = vec4((ndc0 - ndcOffset) * p0.w, p0.z, p0.w);
    v_lineTexCoord = vec2(0.0, 0.0);
    EmitVertex();

    // Vertex 1: Start Point - Right Offset
    gl_Position = vec4((ndc0 + ndcOffset) * p0.w, p0.z, p0.w);
    v_lineTexCoord = vec2(1.0, 0.0);
    EmitVertex();

    // Vertex 2: End Point - Left Offset
    gl_Position = vec4((ndc1 - ndcOffset) * p1.w, p1.z, p1.w);
    v_lineTexCoord = vec2(0.0, 1.0);
    EmitVertex();

    // Vertex 3: End Point - Right Offset
    gl_Position = vec4((ndc1 + ndcOffset) * p1.w, p1.z, p1.w);
    v_lineTexCoord = vec2(1.0, 1.0);
    EmitVertex();

    EndPrimitive();
}
