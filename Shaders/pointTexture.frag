#version 330 core

uniform sampler2D TEXTURE;
uniform vec4 COLOR;

// Independent inputs matching the updated vertex shader variables
flat in uint v_state;
flat in uint v_transparency;
in vec2 v_texCoord; // CRITICAL: Receives the custom UV layout from the Geometry Shader

layout(location = 0) out vec4 o_Color;

void main()
{
    // Correct texture lookup for modern ES 3.1 using the custom geometry coordinates
    // We preserve the 1.0 - Y flip to match standard mobile texture orientation mapping rules
    vec2 uv = vec2(v_texCoord.x, 1.0 - v_texCoord.y); 
    vec4 c = texture(TEXTURE, uv);
    
    // Alpha discard to handle non-blended zero-alpha pixel testing safely
    if (c.a < 0.01) {
        discard;
    }

    if(COLOR.a > 0.0) {
        o_Color = vec4(COLOR.rgb, c.a);
        return;
    }
    o_Color = c;
}
