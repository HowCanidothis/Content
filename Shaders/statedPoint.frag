#version 450

uniform vec4 COLOR;
uniform vec4 COLOR2;
uniform vec4 COLOR3;
uniform vec4 HOVER_COLOR;

in vData
{
    flat uint state;
    flat uint transparency;
} vertex;

out vec4 fragColor;

void main()
{
    vec2 circCoord = 2.0 * gl_PointCoord - 1.0;
    float dist = dot(circCoord, circCoord);
    if (dist > 1.0) {
        discard;
    }

    vec4 color;
    float transparency = 1.0;
    if(vertex.transparency != 255) {
        transparency = float(vertex.transparency) / 255.0;
    }

    if((vertex.state & 1u) == 1u) {
        transparency = 1.0;
        if (dist > 0.4) {
            color = COLOR;
        } else {
            color = HOVER_COLOR;
        }
    } else if((vertex.state & 2u) == 2u) {
        if (dist > 0.4) {
            color = COLOR;
        } else {
            color = COLOR2;
        }
    } else if((vertex.state & 4u) == 4u) {
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
