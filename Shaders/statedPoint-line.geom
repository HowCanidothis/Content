#version 310 es

#extension GL_OES_geometry_shader : require

#undef lowp
#undef mediump
#undef highp

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform highp mat4 MVP;
uniform highp mat4 MODEL_MATRIX;
uniform highp float POINT_SIZE;
uniform highp vec2 SCREEN_SIZE;

// Arrays coming from the Vertex Shader
flat in uint vs_state[];
flat in uint vs_transparency[];

flat out uint v_state;
flat out uint v_transparency;
out highp vec2 v_texCoord;

void main()
{
    // A point primitive has exactly 1 vertex input, located at index 0
    highp vec4 centerClip = MVP * MODEL_MATRIX * gl_in[0].gl_Position;
    
    highp vec3 ndc = centerClip.xyz / centerClip.w;

    // FIX: Must use explicit array index [0] to extract data safely
    highp float ps = POINT_SIZE;
    if ((vs_state[0] & 7u) != 0u) {
        ps *= 1.5;
    }
    highp float halfSize = ps * 0.5;

    highp vec2 offsets[4] = vec2[](
        vec2(-halfSize, -halfSize), // Bottom-Left
        vec2( halfSize, -halfSize), // Bottom-Right
        vec2(-halfSize,  halfSize), // Top-Left
        vec2( halfSize,  halfSize)  // Top-Right
    );

    highp vec2 texCoords[4] = vec2[](
        vec2(0.0, 0.0),
        vec2(1.0, 0.0),
        vec2(0.0, 1.0),
        vec2(1.0, 1.0)
    );

    // FIX: Explicitly assign index [0] to forward properties to the fragment stage
    v_state = vs_state[0];
    v_transparency = vs_transparency[0];

    for (int i = 0; i < 4; i++) {
        highp vec2 ndcOffset = (offsets[i] / SCREEN_SIZE) * 2.0;
        
        gl_Position = vec4((ndc.xy + ndcOffset) * centerClip.w, centerClip.z, centerClip.w);
        v_texCoord = texCoords[i];
        
        EmitVertex();
    }
    EndPrimitive();
}
