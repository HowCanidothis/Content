#version 400

in vData
{
    vec3 vertPos;
    flat vec3 startPos;
    flat uint transparency;
} vertex;

out vec4 fragColor;

uniform vec4 COLOR;
uniform vec2  SCREEN_SIZE;
uniform float u_dashSize = 10.0;
uniform float u_gapSize = 5.0;

void main()
{
    vec2  dir  = (vertex.vertPos.xy- vertex.startPos.xy) * SCREEN_SIZE/2.0;
    float dist = length(dir);

    if (fract(dist / (u_dashSize + u_gapSize)) > u_dashSize/(u_dashSize + u_gapSize))
        discard; 
    fragColor = vec4(COLOR.rgb, vertex.transparency / 255.0);
}