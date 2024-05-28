#version 450

uniform vec4 COLOR;
uniform vec4 COLOR2;
uniform vec4 COLOR3;

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

    if((vertex.state & 2u) == 2u) {
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
    if(vertex.transparency != 255) {
        color.a = float(vertex.transparency) / 255.0;
    }
    fragColor = color;
}
