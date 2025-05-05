#version 450

uniform sampler2D TEXTURE;

out vec4 fragColor;
uniform vec4 COLOR;
uniform vec4 BORDER_COLOR;
uniform float BORDER_WIDTH;
uniform float CONTRAST;

in fData {
   vec2 texCoord;
} frag;

void main() {
    vec2 outTexCord = frag.texCoord;
    vec2 params = vec2(BORDER_WIDTH, CONTRAST);
    vec4 color = COLOR;
    vec3 borderColor = BORDER_COLOR.rgb;
    float tx=texture(TEXTURE, outTexCord).r;
    float a=clamp((params.x - tx)*params.y, 0.0, 1.0);
    fragColor = vec4(mix(color.rgb, borderColor, a), 2.0 * tx);
}
