#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec2 a_texCoord;

out fData {
    vec2 texCoord;
} frag;

void main()
{
    frag.texCoord = a_texCoord;
    gl_Position = MVP * vec4(a_vertex, 1.0);
}