#version 330 core

// 3. Flattened standalone input variables matching your geometry shader outputs exactly
in vec3 v_fragNormal;
in vec3 v_fragPosition;

uniform vec4 COLOR;
uniform vec3 FORWARD;
uniform vec3 EYE;

// 4. Output variable declaration requiring explicit precision qualifiers
out vec4 fragColor;

// Ensure your internal "phong.shader" file is updated to 310 es syntax
#include "phong.shader"

void main()
{
    // Use the flattened v_fragPosition and v_fragNormal fields directly
    fragColor = phongFunction(COLOR.rgb, COLOR.rgb, vec3(1.0), v_fragPosition, v_fragNormal, FORWARD, COLOR.a);
}
