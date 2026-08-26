#version 330 core

uniform vec4 COLOR;
uniform vec4 COLOR2;
uniform vec4 COLOR3;
uniform vec4 HOVER_COLOR;

flat in uint v_state;
flat in uint v_transparency;
in vec2 v_texCoord; // Receives custom UV coordinates from the Geometry Shader

layout(location = 0) out vec4 fragColor;

void main()
{
    // Convert custom UV space [0,1] to [-1, 1] to emulate gl_PointCoord circle math
    vec2 circCoord = 2.0 * v_texCoord - 1.0;
    float dist = dot(circCoord, circCoord);
    
    // Discard fragments outside the radius to shape the square quad into a clean circle
    if (dist > 1.0) {
        discard;
    }

    vec4 color;
    float transparency = 1.0;
    if(v_transparency != 255u) {
        transparency = float(v_transparency) / 255.0;
    }

    // Evaluate states using bitwise operators
    if((v_state & 1u) == 1u) {
        transparency = 1.0;
        if (dist > 0.4) {
            color = COLOR;
        } else {
            color = HOVER_COLOR;
        }
    } else if((v_state & 2u) == 2u) {
        if (dist > 0.4) {
            color = COLOR;
        } else {
            color = COLOR2;
        }
    } else if((v_state & 4u) == 4u) {
        if (dist > 0.4) {
            color = COLOR;
        } else {
            color = COLOR3;
        }
    } else {
        color = COLOR;
    }
    color.a = transparency;
    
    fragColor = color;
}
