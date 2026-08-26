#version 330 core

uniform vec4 COLOR;

// 3. Output variable declaration requiring explicit precision qualifiers
out vec4 fragColor;

void main()
{
    // gl_PointCoord is natively supported in GLSL ES 3.10 for mapping points to circular masks
    vec2 circCoord = 2.0 * gl_PointCoord - 1.0;
    float dist = dot(circCoord, circCoord);
    
    if (dist > 1.0) {
        discard;
    }
    
    fragColor = COLOR;
}
