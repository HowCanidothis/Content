#version 450
uniform vec4 COLOR;

uniform sampler2D TEXTURE;

out vec4 fragColor;
uniform float CONTRAST;

in fData {
   vec2 texCoord; 
} frag;

void main() {
    float pxRange = CONTRAST;
    vec2 outTexCord = frag.texCoord;
    vec2 params = vec2(0.2, 3.0);
    vec4 color = vec4(1.0, 1.0, 1.0, 1.0);
    vec3 borderColor = vec3(0.0, 0.0, 0.0);
    float tx=texture2D(TEXTURE, outTexCord).r;
    float a=clamp((tx-params.x)*params.y, 0.0, 1.0);
    tx *= 2.0;
    fragColor = vec4(mix(borderColor, color.rgb, a) * tx, color.a * tx);
    // fragColor=texture2D(TEXTURE, outTexCord);
}
