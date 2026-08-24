#version 310 es

layout (location = 0) in highp vec3 inPos;
layout (location = 2) in uint transparency;

// ESSL 310 Fix: Use discrete output variables instead of an interface block 
// for maximum mobile driver stability.
out highp float v_dist;
flat out uint vs_transparency;

uniform highp mat4 MVP;

void main()
{
    // 1. Calculate distance metric (High precision for consistent math)
    v_dist = abs(inPos.x) + abs(inPos.y);
    
    // 2. Project position (Note: forcing Z to 0.0 as per your original logic)
    highp vec4 pos = MVP * vec4(vec3(inPos.xy, 0.0), 1.0);
    gl_Position = pos;
    
    // 3. Pass through transparency uint
    vs_transparency = transparency;
}
