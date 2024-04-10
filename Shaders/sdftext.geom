#version 150
#extension GL_EXT_geometry_shader4 : enable

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform sampler2D TEXTURE;
uniform mat4 MVP;
uniform vec2 SCREEN_SIZE;
uniform float TEXT_SCALE;
uniform bool ENABLE_DIR_CORRECTION;
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
    float totalHeight = TEXT_HEIGHT;
    vec2 halfScreenSize = SCREEN_SIZE / 2.0;
    int align = int(vertexData[0].align);
    vec3 sourceOrigin = vertexData[0].position;
    vec4 sourceOffsetDirection = vertexData[0].offsetDirection;
    float advance = vertexData[0].advance;
    float totalWidth  = vertexData[0].totalWidth;
    float voffset = 0.0;

    vec4 origin4 = MVP * vec4(sourceOrigin, 1.0);
    if(origin4.w < 0.01) {
        EndPrimitive();
        return;
    }
    origin4 /= origin4.w;
        
    vec2 origin =  origin4.xy * halfScreenSize + halfScreenSize;

    vec3 sourceDirection = vertexData[0].direction;

    vec2 direction = vec2(1.0, 0.0);
    vec2 stableDirection = vec2(1.0, 0.0);
    if(ENABLE_DIR_CORRECTION) {
        vec4 p2 = MVP * vec4(sourceOrigin + sourceDirection, 1.0);
        p2 /= p2.w;
        vec2 p2xy = p2.xy * halfScreenSize + halfScreenSize;

        stableDirection = (MVP * vec4(sourceDirection, 0.0)).xy;
        direction = normalize(p2xy - origin.xy);
    }
    if(sourceOffsetDirection != vec4(0.0)) {
        vec4 pOffset = MVP * vec4(sourceOffsetDirection.xyz, 0.0);

        if(pOffset.w != 0.0) {
            pOffset /= pOffset.w;
        } else {
            pOffset = -pOffset;
        }
        vec2 offsetDirection = normalize(pOffset.xy);

        /*if(dot(normalize(pOffset.xy), vec2(1.0, 1.0)) < 0.0) {
            EndPrimitive();
            return;
        }*/

        origin -= offsetDirection.xy * sourceOffsetDirection.w;
    }

    if((align & 16) == 16) {
        origin += direction * totalWidth / 2.0 * TEXT_SCALE;
        align |= 3;
    }

    vec2 dirNormal = vec2(direction.y, -direction.x);
    vec2 TEXTURE_SIZE = textureSize(TEXTURE, 0);

    if(dot(dirNormal, vec2(0.0, 1.0)) > 0.0) {
        direction = -direction;
        dirNormal = -dirNormal;
    }

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
    
    vec2 vertex = origin + direction * advance * TEXT_SCALE;
    vec2 texCoord = vertexData[0].texLocation.xy;
    vec2 size = vertexData[0].texLocation.zw;
    float index = vertexData[0].index;
    vec2 offset = vec2((-vertexData[0].offset.x - index * 10.0), (vertexData[0].offset.y + voffset)) * TEXT_SCALE;
    
    float offsetX = size.x * TEXT_SCALE;
    float offsetY = size.y * TEXT_SCALE;
    vec2 topLeft = vertex;
    vec2 bottomLeft = vertex + dirNormal * offsetY;
    vec2 topRight = vertex + offsetX * direction;
    vec2 bottomRight = vertex + offsetX * direction + offsetY * dirNormal;

    vec2 translation = (direction * offset.x - dirNormal * offset.y);
    topLeft -= translation;
    bottomLeft -= translation;
    topRight -= translation;
    bottomRight -= translation;

    vec2 topLeftTexCoord = vec2(texCoord.x / TEXTURE_SIZE.x, texCoord.y / TEXTURE_SIZE.y);
    vec2 bottomLeftTexCoord = vec2(texCoord.x / TEXTURE_SIZE.x, (texCoord.y + size.y)  / TEXTURE_SIZE.y);
    vec2 topRightTexCoord = vec2((texCoord.x + size.x) / TEXTURE_SIZE.x, texCoord.y  / TEXTURE_SIZE.y);
    vec2 bottomRightTexCoord = vec2((texCoord.x + size.x) / TEXTURE_SIZE.x, (texCoord.y + size.y)  / TEXTURE_SIZE.y);

    // 2D text
    
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
    EndPrimitive();
}
