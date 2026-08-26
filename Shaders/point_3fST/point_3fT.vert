#version 330 core

layout (location = 0) in vec3 inPos;
layout (location = 2) in uint transparency;

// ESSL 310 Fix: Use discrete output variables instead of an interface block 
// for maximum mobile driver stability.
flat out uint vs_transparency;

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

void main()
{
    // 2. Project position (Note: forcing Z to 0.0 as per your original logic)
    vec4 pos = MVP * MODEL_MATRIX * vec4(inPos, 1.0);
    gl_Position = pos;
    
    // 3. Pass through transparency uint
    vs_transparency = transparency;
}