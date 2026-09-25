#version 330 core

layout(location = 0) in vec3 a_vertex;
layout(location = 1) in uint a_vertexState;
layout(location = 2) in uint a_vertexTransparency;

uniform mat4 MVP; 
uniform mat4 MODEL_MATRIX;

// u_projectionPlane acts as a mask vector. E.g., vec3(0.0, 0.0, 1.0) means project along Z
uniform vec3 PROJECTION_PLANE=vec3(0.0,0.0,0.0); 
// The actual world coordinate bounding boundary plane to snap onto (e.g., box.Front())
uniform float PLANE_COORDINATE=0.0;

flat out uint vs_state;
flat out uint vs_transparency;

void main()
{
    vs_state = a_vertexState & 0xFFu;
    vs_transparency = a_vertexTransparency & 0xFFu;

    vec4 projectedPos = MODEL_MATRIX * vec4(a_vertex,1.0);

    bool addOffset = false;
    if (PROJECTION_PLANE.x > 0.5) {
        projectedPos.x = PLANE_COORDINATE; // Clamp to YZ plane
        addOffset = true;
    } else if (PROJECTION_PLANE.y > 0.5) {
        projectedPos.y = PLANE_COORDINATE; // Clamp to XZ plane
        addOffset = true;
    } else if (PROJECTION_PLANE.z > 0.5){
        projectedPos.z = PLANE_COORDINATE; // Clamp to XY plane
        addOffset = true;
    }
    vec4 point = MVP * vec4(projectedPos.xyz, 1.0);
    if(addOffset) {
        point.w += 0.01;
    }
    gl_Position = point;
}
