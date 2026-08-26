#version 330 core

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform sampler2D TEXTURE;
uniform mat4 MVP;
uniform float TEXT_SCALE;
uniform float TEXT_HEIGHT;

// Flat inputs matched exactly to your vertex shader
in vec3 v_position[];
in vec4 v_texLocation[];
in vec2 v_offset[];
flat in int v_index[];
in float v_advance[];
in float v_totalWidth[];
flat in int v_align[];
in vec3 v_direction[];
in vec4 v_offsetDirection[];

// Flat output to fragment shader
out vec2 v_fragTexCoord;

void main()
{
    int currentAlign = v_align[0];
    vec3 origin = v_position[0];
    float currentAdvance = v_advance[0];
    float totalHeight = TEXT_HEIGHT;
    float voffset = 0.0;
    float currentTotalWidth  = v_totalWidth[0];

    vec3 srcDirection = v_direction[0];
    vec3 dirNormal = -v_offsetDirection[0].xyz;
    vec2 TEXTURE_SIZE = vec2(textureSize(TEXTURE, 0));

    switch(currentAlign & 3) {
    case 1: currentAdvance = currentAdvance - currentTotalWidth; break;
    case 3: currentAdvance = currentAdvance - currentTotalWidth / 2.0; break;
    default: break;
    }
    switch(currentAlign & 12) {
    case 4: voffset = -totalHeight; break;
    case 12: voffset = -totalHeight / 2.0; break;
    default: break;
    }
    
    vec3 vertex = origin + srcDirection * currentAdvance * TEXT_SCALE;
    vec2 texCoord = v_texLocation[0].xy;
    vec2 size = v_texLocation[0].zw;
    float currentIndex = float(v_align[0]);
    vec2 currentOffset = vec2((-v_offset[0].x - currentIndex * 10.0), (v_offset[0].y + voffset)) * TEXT_SCALE;
    
    float offsetX = size.x * TEXT_SCALE;
    float offsetY = size.y * TEXT_SCALE;
    vec3 topLeft = vertex;
    vec3 bottomLeft = vertex + dirNormal * offsetY;
    vec3 topRight = vertex + offsetX * srcDirection;
    vec3 bottomRight = vertex + offsetX * srcDirection + offsetY * dirNormal;

    vec3 translation = (srcDirection * currentOffset.x - dirNormal * currentOffset.y);
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
    v_fragTexCoord = topLeftTexCoord;
    EmitVertex();
    
    gl_Position = MVP * vec4(bottomLeft, 1.0);
    v_fragTexCoord = bottomLeftTexCoord;
    EmitVertex();
    
    gl_Position = MVP * vec4(topRight, 1.0);
    v_fragTexCoord = topRightTexCoord;
    EmitVertex();
    
    gl_Position = MVP * vec4(bottomRight, 1.0);
    v_fragTexCoord = bottomRightTexCoord;
    EmitVertex();
    
    EndPrimitive();    
}
