#version 330 core

layout(points) in;
layout(triangle_strip, max_vertices = 4) out;

uniform sampler2D TEXTURE;
uniform mat4 MVP;
uniform vec2 SCREEN_SIZE;
uniform float TEXT_SCALE;
uniform bool ENABLE_DIR_CORRECTION;
uniform float TEXT_HEIGHT;

// Входящие массивы с префиксом v_
in vec3 v_position[];
in vec4 v_texLocation[];
in vec2 v_offset[];
flat in int v_index[];
in float v_advance[];
in float v_totalWidth[];
flat in int v_align[];
in vec3 v_direction[];
in vec4 v_offsetDirection[];

// Выходная переменная с префиксом v_
out vec2 v_fragTexCoord;

void main()
{
    float totalHeight = TEXT_HEIGHT;
    vec2 halfScreenSize = SCREEN_SIZE / 2.0;
    
    // Получение данных из массивов по индексу [0]
    int currentAlign = v_align[0];
    vec3 sourceOrigin = v_position[0];
    vec4 sourceOffsetDirection = v_offsetDirection[0];
    float currentAdvance = v_advance[0];
    float currentTotalWidth  = v_totalWidth[0];
    float voffset = 0.0;

    vec4 origin4 = MVP * vec4(sourceOrigin, 1.0);
    if(origin4.w < 0.01) {
        EndPrimitive();
        return;
    }
    origin4 /= origin4.w;
        
    vec2 origin =  origin4.xy * halfScreenSize + halfScreenSize;

    vec3 sourceDirection = v_direction[0];

    vec2 dirVec = vec2(1.0, 0.0);
    vec2 stableDirection = vec2(1.0, 0.0);
    if(ENABLE_DIR_CORRECTION) {
        vec4 p2 = MVP * vec4(sourceOrigin + sourceDirection, 1.0);
        p2 /= p2.w;
        vec2 p2xy = p2.xy * halfScreenSize + halfScreenSize;

        stableDirection = (MVP * vec4(sourceDirection, 0.0)).xy;
        dirVec = normalize(p2xy - origin.xy);
    }
    if(sourceOffsetDirection != vec4(0.0)) {
        vec4 pOffset = MVP * vec4(sourceOffsetDirection.xyz, 0.0);

        if(pOffset.w != 0.0) {
            pOffset /= pOffset.w;
        } else {
            pOffset = -pOffset;
        }
        vec2 targetOffsetDirection = normalize(pOffset.xy);

        origin -= targetOffsetDirection.xy * sourceOffsetDirection.w;
    }

    if((currentAlign & 16) == 16) {
        origin += dirVec * currentTotalWidth / 2.0 * TEXT_SCALE;
        currentAlign |= 3;
    }

    vec2 dirNormal = vec2(dirVec.y, -dirVec.x);
    vec2 TEXTURE_SIZE = vec2(textureSize(TEXTURE, 0));

    if(dot(dirNormal, vec2(0.0, 1.0)) > 0.0) {
        dirVec = -dirVec;
        dirNormal = -dirNormal;
    }

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
    
    vec2 vertex = origin + dirVec * currentAdvance * TEXT_SCALE;
    vec2 texCoord = v_texLocation[0].xy;
    vec2 size = v_texLocation[0].zw;
    float currentIndex = float(v_index[0]);
    vec2 currentOffset = vec2((-v_offset[0].x - currentIndex * 10.0), (v_offset[0].y + voffset)) * TEXT_SCALE;
    
    float offsetX = size.x * TEXT_SCALE;
    float offsetY = size.y * TEXT_SCALE;
    vec2 topLeft = vertex;
    vec2 bottomLeft = vertex + dirNormal * offsetY;
    vec2 topRight = vertex + offsetX * dirVec;
    vec2 bottomRight = vertex + offsetX * dirVec + offsetY * dirNormal;

    vec2 translation = (dirVec * currentOffset.x - dirNormal * currentOffset.y);
    topLeft -= translation;
    bottomLeft -= translation;
    topRight -= translation;
    bottomRight -= translation;

    vec2 topLeftTexCoord = vec2(texCoord.x / TEXTURE_SIZE.x, texCoord.y / TEXTURE_SIZE.y);
    vec2 bottomLeftTexCoord = vec2(texCoord.x / TEXTURE_SIZE.x, (texCoord.y + size.y)  / TEXTURE_SIZE.y);
    vec2 topRightTexCoord = vec2((texCoord.x + size.x) / TEXTURE_SIZE.x, texCoord.y  / TEXTURE_SIZE.y);
    vec2 bottomRightTexCoord = vec2((texCoord.x + size.x) / TEXTURE_SIZE.x, (texCoord.y + size.y)  / TEXTURE_SIZE.y);

    // Вывод вершин в буфер
    
    vec2 outPos = topLeft.xy - halfScreenSize;
    outPos /= halfScreenSize;
    gl_Position = vec4(outPos, 0.0, 1.0);
    v_fragTexCoord = topLeftTexCoord;
    EmitVertex();
    
    outPos = bottomLeft.xy - halfScreenSize;
    outPos /= halfScreenSize;
    gl_Position = vec4(outPos, 0.0, 1.0);
    v_fragTexCoord = bottomLeftTexCoord;
    EmitVertex();
    
    outPos = topRight.xy - halfScreenSize;
    outPos /= halfScreenSize;
    gl_Position = vec4(outPos, 0.0, 1.0);
    v_fragTexCoord = topRightTexCoord;
    EmitVertex();
    
    outPos = bottomRight.xy - halfScreenSize;
    outPos /= halfScreenSize;
    gl_Position = vec4(outPos, 0.0, 1.0);
    v_fragTexCoord = bottomRightTexCoord;
    EmitVertex();
    
    EndPrimitive();
}
