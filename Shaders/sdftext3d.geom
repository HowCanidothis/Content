#version 150
#extension GL_EXT_geometry_shader4 : enable

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform sampler2D TEXTURE;
uniform mat4 MVP;
uniform vec2 SCREEN_SIZE;
uniform vec3 ORIGIN;
uniform vec3 FORWARD;
uniform vec3 UP;

in vData {
   vec3 position;
   vec4 texLocation;
   vec2 offset;
   float index;
   float advance;
   float totalWidth;
} vertexData[];

out fData {
    vec2 texCoord;
} fragData;

void main()
{
    int align = 2;
    vec3 direction = vec4(1.0, 1.0, 1.0);
    vec3 up = -FORWARD;
    vec3 dirNormal = normalize(cross(direction, up));
    vec2 TEXTURE_SIZE = textureSize(TEXTURE, 0);
    float TEXT_SCALE = 2.0;
    float advance = vertexData[0].advance;
    float totalWidth  = vertexData[0].totalWidth;
    float sign = 1.0;
    switch(align) {
    case 0: advance = advance - totalWidth / 2.0; break;
    case 1: advance = advance - totalWidth; break;
    default: break;
    }
    if(dot(UP, dirNormal) > 0.0) {
        advance = -advance;
        sign = -1.0;
    }
    
    vec3 vertex = vertexData[0].position + direction * advance * TEXT_SCALE;
     //+ vec3(sceneOrigin.xy * SCREEN_SIZE / 2.0 + SCREEN_SIZE / 2.0, 0.0);
    vec2 texCoord = vertexData[0].texLocation.xy;
    vec2 size = vertexData[0].texLocation.zw;
    float index = vertexData[0].index;
    vec3 offset = vec3(-vertexData[0].offset.x * TEXT_SCALE - (index * 10.0 * TEXT_SCALE), vertexData[0].offset.y * TEXT_SCALE, 0.0);
    
    float offsetX = size.x * TEXT_SCALE * sign;
    float offsetY = size.y * TEXT_SCALE * sign;
    vec3 topLeft = vertex;
    vec3 bottomLeft = vertex + dirNormal * offsetY;
    vec3 topRight = vertex + offsetX * direction;
    vec3 bottomRight = vertex + offsetX * direction + offsetY * dirNormal;

    vec3 translation = (direction * offset.x - dirNormal * offset.y) * sign;
    topLeft -= translation;
    bottomLeft -= translation;
    topRight -= translation;
    bottomRight -= translation;

    vec2 topLeftTexCoord = vec2(texCoord.x / TEXTURE_SIZE.x, texCoord.y / TEXTURE_SIZE.y);
    vec2 bottomLeftTexCoord = vec2(texCoord.x / TEXTURE_SIZE.x, (texCoord.y + size.y)  / TEXTURE_SIZE.y);
    vec2 topRightTexCoord = vec2((texCoord.x + size.x) / TEXTURE_SIZE.x, texCoord.y  / TEXTURE_SIZE.y);
    vec2 bottomRightTexCoord = vec2((texCoord.x + size.x) / TEXTURE_SIZE.x, (texCoord.y + size.y)  / TEXTURE_SIZE.y);

    // 2D text
 /*   vec2 halfScreenSize = SCREEN_SIZE / 2.0;
    vec2 position = topLeft.xy - halfScreenSize;
    position /= halfScreenSize;
    gl_Position = vec4(position, 0.0, 1.0);
    fragData.texCoord = topLeftTexCoord;
    EmitVertex();
    position = bottomLeft.xy - halfScreenSize;
    position /= halfScreenSize;
    gl_Position = vec4(position, 0.0, 1.0);
    fragData.texCoord = bottomLeftTexCoord;
    EmitVertex();
    position = topRight.xy - halfScreenSize;
    position /= halfScreenSize;
    gl_Position = vec4(position, 0.0, 1.0);
    fragData.texCoord = topRightTexCoord;
    EmitVertex();
    position = bottomRight.xy - halfScreenSize;
    position /= halfScreenSize;
    gl_Position = vec4(position, 0.0, 1.0);
    fragData.texCoord = bottomRightTexCoord;
    EmitVertex();
    EndPrimitive();*/  

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