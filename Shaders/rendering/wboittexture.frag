#version 330 core
#extension GL_ARB_sample_shading : enable

out vec4 outColor;
                                                                      
uniform sampler2DMS colorTextureNT;            
uniform sampler2DMS mixedTexture;              
uniform sampler2DMS transparentWithDepthTexture;                
                                                                      
void main() {                                                         
    ivec2 upos = ivec2(gl_FragCoord.xy);                              

    vec4 mixed = texelFetch(mixedTexture, upos, gl_SampleID);
    vec4 depthTransparent = texelFetch(transparentWithDepthTexture, upos, gl_SampleID);                                                                                                                                           
    vec3 colorNT = texelFetch(colorTextureNT, upos, gl_SampleID).rgb;
    float sumOfWeights = mixed.a;
                                                                      
    if (sumOfWeights == 0.0) {
        outColor = vec4(colorNT, 1.0);
        return;
    }                                                       
    outColor = vec4(mix(colorNT.rgb, mix(mixed.rgb, depthTransparent.rgb, depthTransparent.a), 0.5), 1.0);
}
