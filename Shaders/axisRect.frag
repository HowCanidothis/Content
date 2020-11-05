#version 450
uniform vec4 COLOR;
uniform sampler2D Texture;
uniform vec2 MULTIPLIER;

out vec4 fragColor;

in fData {
    vec2 texCoord;
} frag;

void main()
{
    fragColor = texture(Texture, frag.texCoord * MULTIPLIER);
}