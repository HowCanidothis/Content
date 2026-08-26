#version 330 core

uniform sampler2D TEXTURE;
uniform vec4 BORDER_COLOR;
uniform float BORDER_WIDTH;
uniform float CONTRAST;

// Flattened standalone input variables matching your geometry shader outputs exactly
in vec2 v_fragTexCoord;
in vec3 v_fragColor;

// Output variable declaration
out vec4 fragColor;

void main() {
    vec2 outTexCord = v_fragTexCoord;
    vec2 params = vec2(BORDER_WIDTH, CONTRAST);
    
    // Use the per-instance color passed from the geometry shader
    vec4 color = vec4(v_fragColor, 1.0);
    vec3 borderColor = BORDER_COLOR.rgb;
    
    // Modern texture lookup function for GLSL ES 3.10
    float tx = texture(TEXTURE, outTexCord).r;
    float a = clamp((params.x - tx) * params.y, 0.0, 1.0);
    
    fragColor = vec4(mix(color.rgb, borderColor, a), 2.0 * tx);
}
