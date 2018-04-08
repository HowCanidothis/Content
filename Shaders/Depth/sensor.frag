#version 450
/*uniform Transform
{
    mat4 projection;
    mat4 view;
    mat4 MVP;
};*/
in vec2 v_texCoord;
in vec4 v_shadowCoord;
layout(location = 0) out vec4 o_Color;
uniform usampler2D HeightMap;
uniform sampler2D SandTex;
uniform sampler2D GrassTex;
uniform sampler2D MountainTex;
uniform sampler2D ShadowMap;

uniform vec3 LightDirection;

void main()
{
    //float s11 = texture(HeightMap, v_texCoord).r;
    float left = textureOffset(HeightMap, v_texCoord, ivec2(-1, 0), 0.1).r;
    float right = textureOffset(HeightMap, v_texCoord, ivec2(1, 0), 0.1).r;
    float bottom = textureOffset(HeightMap, v_texCoord, ivec2(0, -1), 0.1).r;
    float top = textureOffset(HeightMap, v_texCoord, ivec2(0, 1), 0.1).r;
    float x = 2.0 * (left - right);
    float y = 2.0 * (bottom - top);
    float z = -4.0;
    vec3 normal = normalize(vec3(x,y,z));
    float bumpIntensity = dot(LightDirection, normal);
    float shadowIntensity = 1.0;

    float bias = 0.005;
    float multiplier10 = 10.0;
    float shadowMapValue = texture(ShadowMap, v_shadowCoord.xy).x;
    if(shadowMapValue < (v_shadowCoord.z - bias)) {
        shadowIntensity = 0.5;
    }

    float totalIntensity = (0.7 + 0.15 * bumpIntensity + 0.15 * shadowIntensity);

    uint color = texture(HeightMap, v_texCoord).r;
    if(color == 0) {
        o_Color = vec4(0.0,0.0,0.0,1.0);
    }
    else if(color < 10) {
        o_Color = vec4(1.0,1.0,0.0,1.0);
    }
    else if(color < 30) {
        o_Color = vec4(1.0,0.0,0.0,1.0);
    }
    else if(color < 30) {
        o_Color = vec4(0.0,0.0,1.0,1.0);
    }
    else if(color < 40) {
        o_Color = vec4(0.0,1.0,0.0,1.0);
    }
    else if(color < 50) {
        o_Color = vec4(1.0,0.0,0.0,1.0);
    }
    else if(color < 60) {
        o_Color = vec4(0.0,1.0,0.0,1.0);
    }
    else if(color < 70) {
        o_Color = vec4(0.0,0.0,1.0,1.0);
    }
    else if(color < 80) {
        o_Color = vec4(1.0,0.0,0.0,1.0);
    }
    else if(color < 90) {
        o_Color = vec4(0.0,1.0,0.0,1.0);
    }
    else if(color < 100) {
        o_Color = vec4(1.0,1.0,1.0,1.0);
    }
    else if(color < 2150) {
        o_Color = totalIntensity * texture(MountainTex, v_texCoord * multiplier10);
    }
    else if(color < 2200) {
        vec4 mountain = texture(MountainTex, v_texCoord * multiplier10);
        vec4 grass = texture(GrassTex, v_texCoord  * multiplier10);
        o_Color = totalIntensity * mix(mountain, grass, float(color - 2150) / 50.0);
    }
    else {
        vec4 sand = texture(SandTex, v_texCoord * multiplier10);
        vec4 grass = texture(GrassTex, v_texCoord  * multiplier10);
        o_Color = totalIntensity * mix(grass, sand, clamp(float(color - 2200) / 50.0, 0.0, 1.0));
    }
}