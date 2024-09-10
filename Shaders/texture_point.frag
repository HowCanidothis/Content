#version 450

uniform sampler2D TEXTURE;
uniform vec4 COLOR;

out vec4 o_Color;

void main()
{
    vec4 c = texture2D(TEXTURE, gl_PointCoord);
    if(COLOR.a > 0.0) {
        o_Color = vec4(COLOR.rgb, c.a);
        return;
    }
    o_Color = c;
}