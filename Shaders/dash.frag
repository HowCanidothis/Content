#version 400

in vData
{
    float dist;
    flat uint transparency;
} vertex;

out vec4 fragColor;

uniform vec4 COLOR;
uniform vec2  SCREEN_SIZE;
uniform uint pattern[10] = {1,1,1,1,0,1,1,1,1,0};

void main()
{
    vec4 fcoord = gl_FragCoord;
    float dist = fcoord.x + fcoord.y;
    float modulo = mod(dist, 50.0) / 5.0;
    uint patternValue = pattern[int(modulo)];
    if(patternValue == 0)
       discard;

    if(fract(modulo) != 0.0 && pattern[int(mod(modulo + 1, 10))] == 0.0) {
        discard;
    }


    fragColor = COLOR;
}