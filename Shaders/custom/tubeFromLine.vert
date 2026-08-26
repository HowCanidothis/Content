#version 330 core

// Explicit layout location kept for 'in' attribute only
layout(location = 0) in vec3 vertexPosition;

// Renamed standard output variable
out vec4 v_vertexPos;

void main()
{
    v_vertexPos = vec4(vertexPosition, 1.0);
    gl_Position = v_vertexPos;
}
