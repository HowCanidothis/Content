#version 330 core

uniform vec4 COLOR;

flat in uint v_transparency;
in vec2 v_lineTexCoord; // Receives custom UV coordinates from the geometry shader

layout(location = 0) out vec4 fragColor;

void main()
{
    // Compute alpha fading along the outer 15% edges for built-in anti-aliasing
    float distFromCenter = abs(v_lineTexCoord.x - 0.5) * 2.0; 
    float edgeAlpha = 1.0 - smoothstep(0.85, 1.0, distFromCenter);
    
    // Mix the base uniform color with the vertex data transparency
    float finalAlpha = (float(v_transparency) / 255.0) * edgeAlpha;
    
    vec4 finalColor = vec4(COLOR.rgb, finalAlpha);
    
    if (finalColor.a < 0.01) {
        discard;
    }

    fragColor = finalColor;
}
