#version 150
#extension GL_EXT_geometry_shader4 : enable

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform sampler2D TEXTURE;
uniform mat4 MVP;
uniform float TEXT_SCALE;
uniform float TEXT_HEIGHT;

in vData {
   vec3 position;
   vec4 texLocation;
   vec2 offset;
   float index;
   float advance;
   float totalWidth;
   float align;
   vec3 direction;
   vec4 offsetDirection;
} vertexData[];

out fData {
    vec2 texCoord;
} fragData;

void main()
{
    int align = int(vertexData[0].align);
    vec3 origin = vertexData[0].position;
    float advance = vertexData[0].advance;
    float totalHeight = TEXT_HEIGHT;
    float voffset = 0.0;
    float totalWidth  = vertexData[0].totalWidth;

    vec3 direction = vertexData[0].direction;
    vec3 dirNormal = -vertexData[0].offsetDirection.xyz;
    vec2 TEXTURE_SIZE = textureSize(TEXTURE, 0);

    switch(align & 3) {
    case 1: advance = advance - totalWidth; break;
    case 3: advance = advance - totalWidth / 2.0; break;
    default: break;
    }
    switch(align & 12) {
    case 4: voffset = -totalHeight; break;
    case 12: voffset = -totalHeight / 2.0; break;
    default: break;
    }
    
    vec3 vertex = origin + direction * advance * TEXT_SCALE;
    vec2 texCoord = vertexData[0].texLocation.xy;
    vec2 size = vertexData[0].texLocation.zw;
    float index = vertexData[0].index;
    vec2 offset = vec2((-vertexData[0].offset.x - index * 10.0), (vertexData[0].offset.y + voffset)) * TEXT_SCALE;
    
    float offsetX = size.x * TEXT_SCALE;
    float offsetY = size.y * TEXT_SCALE;
    vec3 topLeft = vertex;
    vec3 bottomLeft = vertex + dirNormal * offsetY;
    vec3 topRight = vertex + offsetX * direction;
    vec3 bottomRight = vertex + offsetX * direction + offsetY * dirNormal;

    vec3 translation = (direction * offset.x - dirNormal * offset.y);
    topLeft -= translation;
    bottomLeft -= translation;
    topRight -= translation;
    bottomRight -= translation;

    vec2 topLeftTexCoord = vec2(texCoord.x / TEXTURE_SIZE.x, texCoord.y / TEXTURE_SIZE.y);
    vec2 bottomLeftTexCoord = vec2(texCoord.x / TEXTURE_SIZE.x, (texCoord.y + size.y)  / TEXTURE_SIZE.y);
    vec2 topRightTexCoord = vec2((texCoord.x + size.x) / TEXTURE_SIZE.x, texCoord.y  / TEXTURE_SIZE.y);
    vec2 bottomRightTexCoord = vec2((texCoord.x + size.x) / TEXTURE_SIZE.x, (texCoord.y + size.y)  / TEXTURE_SIZE.y);

  // 3D text
    gl_Position = MVP * vec4(topLeft, 1.0);
    fragData.texCoord = topLeftTexCoord;
    EmitVertex();
    gl_Position = MVP * vec4(bottomLeft, 1.0);
    fragData.texCoord = bottomLeftTexCoord;
    EmitVertex();
    gl_Position = MVP * vec4(topRight, 1.0);
    fragData.texCoord = topRightTexCoord;
    EmitVertex();
    gl_Position = MVP * vec4(bottomRight, 1.0);
    fragData.texCoord = bottomRightTexCoord;
    EmitVertex();
    EndPrimitive();    

}