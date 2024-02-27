#version 330

flat in vec3 startPos;
in vec3 vertPos;

out vec4 fragColor;

uniform vec4 COLOR;
uniform vec2  SCREEN_SIZE;
uniform float u_dashSize = 10.0;
uniform float u_gapSize = 5.0;

void main()
{
    vec2  dir  = (vertPos.xy-startPos.xy) * SCREEN_SIZE/2.0;
    float dist = length(dir);

    if (fract(dist / (u_dashSize + u_gapSize)) > u_dashSize/(u_dashSize + u_gapSize))
        discard; 
    fragColor = vec4(COLOR.rgb, 1.0);
}