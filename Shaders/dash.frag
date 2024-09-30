#version 400

in vData
{
    float dist;
    flat uint transparency;
} vertex;

out vec4 fragColor;

uniform vec4 COLOR;
uniform vec2  SCREEN_SIZE;
uniform float u_dashSize = 0.02;
uniform float u_gapSize = 0.005;

void main()
{
    if (fract(vertex.dist / (u_dashSize + u_gapSize)) > u_dashSize/(u_dashSize + u_gapSize))
        discard; 
    fragColor = vec4(COLOR.rgb, float(vertex.transparency) / 255.0);
}