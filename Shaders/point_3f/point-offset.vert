#version 330 core

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;
uniform float OFFSET_UNITS=0.0;

layout(location = 0) in vec3 a_vertex;

// ESSL 310 Fix: Replaced interface block with a discrete out variable 
// to maximize driver compatibility and stability on mobile GPUs.
void main()
{   
    // Calculate final Clip Space coordinates
    vec4 point = MVP * MODEL_MATRIX * vec4(a_vertex, 1.0);
    point.w += OFFSET_UNITS;
    gl_Position = point;
}
