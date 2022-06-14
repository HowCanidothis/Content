#version 450
layout(location = 0) in vec2 a_vertex;
layout(location = 1) in vec3 a_color;

uniform vec2 SCREEN_SIZE;

out fData
{
  vec2 position;
  vec3 color;
} frag;

void main()
{
    frag.position = vec2(a_vertex.x, SCREEN_SIZE.y - a_vertex.y);
    frag.color = a_color;
    vec2 halfScreenSize = SCREEN_SIZE / 2.0;
    gl_Position = vec4((frag.position - halfScreenSize) / halfScreenSize, 0.0, 1.0);
}