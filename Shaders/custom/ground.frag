#version 330 core

// 3. Flattened input variables matching your vertex/geometry shader outputs exactly
in vec3 v_fragNormal;
in vec3 v_fragPosition;
in vec4 v_fragColor;
in float v_fragT;
flat in int v_fragApplyLight; // Enforce int/uint back-mapping if boolean linking fails

uniform vec3 GRADIENT_COLOR;
uniform vec3 EYE;
uniform vec3 FORWARD;
uniform mat4 MVP;

#line 19
// Note: Ensure your internal helper files are updated to 310 es syntax and use highp!
#include "math.shader"
#include "phong.shader"

out vec4 fragColor;

// Stable 3D Hash generator
vec3 hash3D(vec3 p) {
    p = vec3(dot(p, vec3(127.1, 311.7, 74.7)),
             dot(p, vec3(269.5, 183.3, 246.1)),
             dot(p, vec3(113.5, 271.9, 124.6)));
    return fract(sin(p) * 43758.5453123);
}

// Optimized 3D Value Noise using direct component summation instead of dot products
float valueNoise3D(vec3 p) {
    vec3 i = floor(p); 
    vec3 f = fract(p);
    vec3 u = f * f * (3.0 - 2.0 * f);
    
    vec3 h000 = hash3D(i);
    vec3 h100 = hash3D(i + vec3(1.0, 0.0, 0.0));
    vec3 h010 = hash3D(i + vec3(0.0, 1.0, 0.0));
    vec3 h110 = hash3D(i + vec3(1.0, 1.0, 0.0));
    vec3 h001 = hash3D(i + vec3(0.0, 0.0, 1.0));
    vec3 h101 = hash3D(i + vec3(1.0, 0.0, 1.0));
    vec3 h011 = hash3D(i + vec3(0.0, 1.0, 1.0));
    vec3 h111 = hash3D(i + vec3(1.0, 1.0, 1.0));

    float v000 = h000.x + h000.y + h000.z;
    float v100 = h100.x + h100.y + h100.z;
    float v010 = h010.x + h010.y + h010.z;
    float v110 = h110.x + h110.y + h110.z;
    float v001 = h001.x + h001.y + h001.z;
    float v101 = h101.x + h101.y + h101.z;
    float v011 = h011.x + h011.y + h011.z;
    float v111 = h111.x + h111.y + h111.z;

    return mix(mix(mix(v000, v100, u.x), mix(v010, v110, u.x), u.y),
               mix(mix(v001, v101, u.x), mix(v011, v111, u.x), u.y), u.z);
}

// Unrolled 3-octave Fractal Brownian Motion loop
float fbm3D(vec3 p) {
    float v = 0.0; 
    v += 0.5 * valueNoise3D(p); p *= 2.5;
    v += 0.25 * valueNoise3D(p); p *= 2.5;
    v += 0.125 * valueNoise3D(p);
    return v;
}

// Voronoi crack generator with integrated density masking
float lightningCracks3D(vec3 p, out float centerMask) {
    vec3 i_p = floor(p); 
    vec3 f_p = fract(p);
    float d1 = 8.0; 
    float d2 = 18.0;

    for (int z = -1; z <= 1; z++) {
        float fz = float(z);
        for (int y = -1; y <= 1; y++) {
            float fy = float(y);
            for (int x = -1; x <= 1; x++) {
                vec3 cellOffset = vec3(float(x), fy, fz);
                vec3 cellPos = hash3D(i_p + cellOffset);
                vec3 toTarget = cellOffset + cellPos - f_p;
                float dist = dot(toTarget, toTarget); 

                if (dist < d1) { 
                    d2 = d1; 
                    d1 = dist; 
                } else if (dist < d2) { 
                    d2 = dist; 
                }
            }
        }
    }

    centerMask = pow(smoothstep(0.1, 0.9, d1), 2.0);
    return 1.0 - smoothstep(0.0, 0.15, d2 - d1);
}

void main()
{
    // Replaced interface variables with flat shader properties
    vec4 color = vec4(mix(v_fragColor.rgb, GRADIENT_COLOR, v_fragT), v_fragColor.a);
  
    // Isotropic scaling with surface normal bias injection
    vec3 noisePosition = v_fragPosition * 12.0 + normalize(v_fragNormal) * 0.1;

    // Domain warping coordinate distribution
    vec3 warpPosition = noisePosition * 1.5;
    
    // FIXED: Cleaned up the vector constructor to pull strictly from 3D FBM calls
    vec3 warp = vec3(fbm3D(warpPosition), 
                           fbm3D(warpPosition + vec3(4.0)), 
                           fbm3D(warpPosition + vec3(8.0)));
                           
    noisePosition += (warp - 0.5) * 0.15; 

    float centerMask;
    float rawCrack = lightningCracks3D(noisePosition, centerMask);
  
    float finalCrack = (rawCrack * rawCrack) * (centerMask * 3.0);
    float crackMask = step(0.9, finalCrack);
  
    // High-frequency pseudo-random grain texture for background shading
    float groundTexture = fract(sin(dot(floor(v_fragPosition * 40.0), vec3(12.9898, 78.233, 45.164))) * 43758.5453);
    vec3 groundBase = mix(color.rgb * 0.9, color.rgb * 1.05, groundTexture * 0.15);
  
    vec3 dynamicCrackColor = color.rgb * 0.8; 
  
    color.rgb = mix(groundBase, dynamicCrackColor, crackMask);

    // Flat bool properties use implicit integer evaluations for multi-GPU driver mapping safety
    if (v_fragApplyLight == 0) {
        fragColor = color;
        return;
    }
  
    fragColor = phongFunction(color.rgb, color.rgb, vec3(0.2), v_fragPosition, v_fragNormal, FORWARD, 1.0);
}
