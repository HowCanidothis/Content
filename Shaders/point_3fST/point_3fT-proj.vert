#version 330 core

layout (location = 0) in vec3 inPos;
layout (location = 2) in uint transparency;

// ESSL 310 Fix: Use discrete output variables instead of an interface block 
// for maximum mobile driver stability.
flat out uint vs_transparency;

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

// u_projectionPlane acts as a mask vector. E.g., vec3(0.0, 0.0, 1.0) means project along Z
uniform vec3 PROJECTION_PLANE; 
// The actual world coordinate bounding boundary plane to snap onto (e.g., box.Front())
uniform float PLANE_COORDINATE;

void main()
{
    // 1. Mathematically flatten the incoming vertex onto the targeted cube wall
    vec4 projectedPos = MODEL_MATRIX * vec4(inPos,1.0);
    
    bool addOffset = false;
    if (PROJECTION_PLANE.x > 0.5) {
        projectedPos.x = PLANE_COORDINATE; // Clamp to YZ plane
        addOffset = true;
    } else if (PROJECTION_PLANE.y > 0.5) {
        projectedPos.y = PLANE_COORDINATE; // Clamp to XZ plane
        addOffset = true;
    } else if (PROJECTION_PLANE.z > 0.5){
        projectedPos.z = PLANE_COORDINATE; // Clamp to XY plane
        addOffset = true;
    }

    // 2. Project position using your engine's default matrix layout
    vec4 pos = MVP * vec4(projectedPos.xyz, 1.0);
    if(addOffset) {
        pos.w += 0.01;
    }
    gl_Position = pos;
    
    // 3. Pass through transparency uint
    vs_transparency = transparency;
}