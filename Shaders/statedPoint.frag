#version 400

uniform vec4 COLOR;
uniform vec4 COLOR2;
uniform vec4 COLOR3;

in vData
{
    flat uint state;
} vertex;

out vec4 fragColor;

void main()
{
    vec2 circCoord = 2.0 * gl_PointCoord - 1.0;
    float dist = dot(circCoord, circCoord);
    if (dist > 1.0) {
        discard;
    }

    if((vertex.state & 2u) == 2u) {
        if (dist > 0.4) {
            fragColor = COLOR;
        } else {
            fragColor = COLOR2;
        }
    } else if((vertex.state & 4u) == 4u) {
        if (dist > 0.4) {
            fragColor = COLOR;
        } else {
            fragColor = COLOR3;
        }
    } else {
        fragColor = COLOR;
    }

}
