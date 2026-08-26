#version 330 core

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform sampler2D TEXTURE;
uniform vec3 FORWARD;
uniform vec2 SCREEN_SIZE;
uniform float TEXT_SCALE;
uniform float TEXT_HEIGHT;

// Flattened array inputs matching your updated vertex shader outputs
in vec2 v_position[];
in vec4 v_texLocation[];
in vec2 v_offset[];
in vec3 v_color[];
flat in int v_index[];
in float v_advance[];
in float v_totalWidth[];
flat in int v_align[];
in vec2 v_direction[];

// Flattened standalone outputs going to your fragment shader
out vec2 v_fragTexCoord;
out vec3 v_fragColor;

void main()
{
    vec2 halfScreenSize = SCREEN_SIZE / 2.0;
    
    // Read the points cleanly from index array allocations
    int align = v_align[0];
    vec3 color = v_color[0];
    vec2 sourceOrigin = v_position[0];
    float advance = v_advance[0];
    float totalHeight = TEXT_HEIGHT;
    float voffset = 0.0;
    float totalWidth  = v_totalWidth[0];

    vec2 origin = vec2(sourceOrigin.x, SCREEN_SIZE.y - sourceOrigin.y);
    vec2 direction = v_direction[0];

    vec2 dirNormal = vec2(direction.y, -direction.x);
    
    // Convert ivec2 from textureSize cleanly into floats for vector math
    vec2 TEXTURE_SIZE = vec2(textureSize(TEXTURE, 0));

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

    if(dot(dirNormal, vec2(0.0, 1.0)) > 0.0) {
        direction = -direction;
        dirNormal = -dirNormal;
    }
    
    vec2 vertex = origin + direction * advance * TEXT_SCALE;
    vec2 texCoord = v_texLocation[0].xy;
    vec2 size = v_texLocation[0].zw;
    int index = v_index[0];
    vec2 offset = vec2((-v_offset[0].x - float(index) * 10.0), (v_offset[0].y + voffset)) * TEXT_SCALE;
    
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

    // =========================================================================
    // OUTPUT FLATTENED GLYPH QUAD VERTICES WITH PER-INSTANCE COLOR
    // =========================================================================
    vec2 position = topLeft.xy - halfScreenSize;
    position /= halfScreenSize;
    gl_Position = vec4(position, 0.0, 1.0);
    v_fragTexCoord = topLeftTexCoord; // Explicit duplicate assignments before emission
    v_fragColor = color;
    EmitVertex();
    
    position = bottomLeft.xy - halfScreenSize;
    position /= halfScreenSize;
    gl_Position = vec4(position, 0.0, 1.0);
    v_fragTexCoord = bottomLeftTexCoord;
    v_fragColor = color;
    EmitVertex();
    
    position = topRight.xy - halfScreenSize;
    position /= halfScreenSize;
    gl_Position = vec4(position, 0.0, 1.0);
    v_fragTexCoord = topRightTexCoord;
    v_fragColor = color;
    EmitVertex();
    
    position = bottomRight.xy - halfScreenSize;
    position /= halfScreenSize;
    gl_Position = vec4(position, 0.0, 1.0);
    v_fragTexCoord = bottomRightTexCoord;
    v_fragColor = color;
    EmitVertex();
    
    EndPrimitive();
}
