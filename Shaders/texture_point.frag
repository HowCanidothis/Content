#version 450

uniform sampler2D TEXTURE;

out vec4 o_Color;

void main()
{
    o_Color = texture2D(TEXTURE, gl_PointCoord);
}