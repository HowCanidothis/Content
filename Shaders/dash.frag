#version 330 core

out vec4 f_fragColor;

flat in vec2 v_screenDir;

uniform vec4 COLOR;

uniform uint pattern[10];

void main()
{
    // 1. Calculate the screen-space distance along the line direction vector
    float dist = dot(gl_FragCoord.xy, v_screenDir);
    
    // 2. Loop every 50 screen pixels. Each element gets exactly 5 pixels of width.
    float modulo = mod(dist, 50.0) / 5.0;
    
    // 3. Keep the index safe inside bounds
    int index = clamp(int(modulo), 0, 9);
    
    // 4. Look up our visibility bit
    uint patternValue = pattern[index];
    
    // If the bit is zero, this 5-pixel segment becomes a gap
    if (patternValue == 0u) {
       discard;
    }

    // 5. Render the remaining visible 5-pixel squares/dots
    f_fragColor = COLOR;
}
