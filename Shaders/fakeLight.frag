#version 330 core

// 3. Flattened standalone input variables matching your vertex/geometry shader outputs exactly
in vec3 v_fragNormal;
in vec3 v_fragPosition;

uniform vec4 COLOR;
uniform vec3 FORWARD;

// 4. Output variable declaration requiring explicit precision qualifiers
out vec4 fragColor;

#line 0
// Note: Ensure your internal "fakeLight.shader" utility is updated 
// to use 'highp' parameters and '310 es' compatible syntax without parameter qualifiers.
#include "fakeLight.shader"

void main()
{
    // FIXED: Replaced 'frag.position' and 'frag.normal' with flattened versions
    fragColor = phongFunction(COLOR.rgb, COLOR.rgb, vec3(1.0), v_fragPosition, v_fragNormal, vec3(0.0, 0.0, -1.0), COLOR.a);
}
