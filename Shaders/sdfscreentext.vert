#version 450
layout(location = 0) in vec2 a_vertex;
layout(location = 1) in vec4 a_texLocation;
layout(location = 2) in vec2 a_offsets;
layout(location = 3) in vec4 a_params;
layout(location = 4) in vec2 a_direction;

out vData {
   vec2 position;
   vec4 texLocation;
   vec2 offset;
   float index;
   float advance;
   float totalWidth;
   float align;
   vec2 direction;
} vertexData;

void main()
{
    vertexData.texLocation = a_texLocation;
    vertexData.offset = a_offsets;
    vertexData.position = a_vertex;
    vertexData.index = a_params[0];
    vertexData.advance = a_params[1];
    vertexData.totalWidth = a_params[3];
    vertexData.direction = a_direction;
    vertexData.align = a_params[2];
}