#version 330 core

out vec4 f_fragColor;

uniform vec4 COLOR;
uniform vec2 SCREEN_SIZE;

uniform uint pattern[10];

void main()
{
    vec2 fcoord = gl_FragCoord.xy;
    
    float dist = fcoord.x + fcoord.y;
    float modulo = mod(dist, 50.0) / 5.0;
    
    int index = clamp(int(modulo), 0, 9);
    uint patternValue = pattern[index];
    
    if (patternValue == 0u) {
       discard;
    }

    int nextIndex = clamp(int(mod(modulo + 1.0, 10.0)), 0, 9);
    if (fract(modulo) != 0.0 && pattern[nextIndex] == 0u) {
        discard;
    }

    f_fragColor = COLOR;
}
