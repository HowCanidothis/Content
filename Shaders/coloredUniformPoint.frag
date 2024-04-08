#version 400

uniform vec4 COLOR;

out vec4 fragColor;

void main()
{
    vec2 circCoord = 2.0 * gl_PointCoord - 1.0;
    float dist = dot(circCoord, circCoord);
    if (dist > 1.0) {
        discard;
    }
    
    fragColor = COLOR;
}
