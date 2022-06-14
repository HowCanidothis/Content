#version 450

uniform sampler2D TEXTURE;

out vec4 fragColor;
uniform vec4 BORDER_COLOR;
uniform float BORDER_WIDTH;
uniform float CONTRAST;

in fData {
   vec2 texCoord;
   vec3 color;
} frag;

void main() {
    vec2 outTexCord = frag.texCoord;
    vec2 params = vec2(BORDER_WIDTH, CONTRAST);
    vec4 color = vec4(frag.color, 1.0);
    vec3 borderColor = BORDER_COLOR.rgb;
    float tx=texture(TEXTURE, outTexCord).r;
    float a=clamp((tx-params.x)*params.y, 0.0, 1.0);
    tx *= 2.0;
    fragColor = vec4(mix(borderColor, color.rgb, a) * tx, color.a * tx);
}
