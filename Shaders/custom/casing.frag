#version 330 core

// 3. Flattened standalone input variables matching your vertex shader outputs exactly
in vec3 v_fragNormal;
in vec3 v_fragPosition;
in vec4 v_fragColor;
in float v_fragT;
flat in int v_fragApplyLight; // Matches the 'flat out int' layout from vertex stage

uniform vec3 GRADIENT_COLOR;
uniform vec3 EYE;
uniform vec3 FORWARD;
uniform mat4 MVP;

#line 19
// Note: Ensure your internal helper files are updated to 310 es syntax and use highp!
#include "math.shader"
#include "phong.shader"

// 4. Output variable declaration requiring explicit precision qualifiers
out vec4 fragColor;

void main()
{
    // Compute interpolated gradient baseline using flattened input variables
    vec4 color = vec4(mix(v_fragColor.rgb, GRADIENT_COLOR, v_fragT), v_fragColor.a);
  
    // Evaluate flat lighting parameter matching integer state parameters
    if (v_fragApplyLight == 0) {
        fragColor = color;
        return;
    }
  
    // Run the high-precision Phong shader light calculations
    fragColor = phongFunction(color.rgb, color.rgb, vec3(1.0), v_fragPosition, v_fragNormal, FORWARD, 1.0);
}
