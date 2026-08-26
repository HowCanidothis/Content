#version 330 core

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform float POINT_SIZE;
uniform vec2 SCREEN_SIZE;

// Arrays coming from the Vertex Shader
flat in uint vs_state[];
flat in uint vs_transparency[];

flat out uint v_state;
flat out uint v_transparency;
out vec2 v_texCoord;

void main()
{
    // High Performance: Read the pre-projected 4D Clip Space coordinate straight from gl_in
    vec4 centerClip = gl_in[0].gl_Position;
    
    if (centerClip.w <= 0.0) return; // Quick camera near-plane safety out
    
    vec3 ndc = centerClip.xyz / centerClip.w;

    float ps = POINT_SIZE;
    if ((vs_state[0] & 7u) != 0u) {
        ps *= 1.5;
    }
    float halfSize = ps * 0.5;

    vec2 offsets[4] = vec2[](
        vec2(-halfSize, -halfSize), // Bottom-Left
        vec2( halfSize, -halfSize), // Bottom-Right
        vec2(-halfSize,  halfSize), // Top-Left
        vec2( halfSize,  halfSize)  // Top-Right
    );

    vec2 texCoords[4] = vec2[](
        vec2(0.0, 0.0), vec2(1.0, 0.0),
        vec2(0.0, 1.0), vec2(1.0, 1.0)
    );

    for (int i = 0; i < 4; i++) {
        vec2 ndcOffset = (offsets[i] / SCREEN_SIZE) * 2.0;
        
        // Re-inject perspective depth scaling factor (w) to preserve screen dimensions
        gl_Position = vec4((ndc.xy + ndcOffset) * centerClip.w, centerClip.z, centerClip.w);
        
        v_texCoord = texCoords[i];
        v_state = vs_state[0];
        v_transparency = vs_transparency[0];
        
        EmitVertex();
    }
    EndPrimitive();
}
