#version 450
layout(location = 0) in vec3 a_vertex;

uniform vec2 SCREEN_SIZE;

out fData
{
  vec2 position;
} frag;

void main()
{
    frag.position = vec2(a_vertex.x, SCREEN_SIZE.y - a_vertex.y);
    vec2 halfScreenSize = SCREEN_SIZE / 2.0;
    gl_Position = vec4((frag.position - halfScreenSize) / halfScreenSize, 0.0, 1.0);
}