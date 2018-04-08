#version 450

layout(location = 0) out vec4 o_Color;
uniform sampler2D TextureMap;
in vec2 v_texCoords;

void main()
{
    float color = texture(TextureMap, v_texCoords).r;
    o_Color = vec4(color, color, color, 1.0);
}