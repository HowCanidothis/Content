#version 310 es

uniform highp mat4 MVP;
uniform highp mat4 MODEL_MATRIX;

layout(location = 0) in highp vec3 a_vertex;

// ESSL 310 Fix: Replaced interface block with a discrete out variable 
// to maximize driver compatibility and stability on mobile GPUs.
out highp vec3 v_fragPosition;

void main()
{
    // Pass the raw local vertex position down the pipeline
    v_fragPosition = a_vertex;
    
    // Calculate final Clip Space coordinates
    gl_Position = MVP * MODEL_MATRIX * vec4(a_vertex, 1.0);
}
