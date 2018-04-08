#version 450
    /*uniform Transform
    {
       mat4 projection;
       mat4 view;
       mat4 MVP;
    };*/
uniform mat4 MVP;
uniform mat4 ShadowMVP;
uniform usampler2D HeightMap;
layout(location = 0) in vec2 a_vertex;
layout(location = 1) in vec2 a_texCoord;
out vec2 v_texCoord;
out vec4 v_shadowCoord;

void main()
{
    uint height = texture(HeightMap, a_texCoord).r;
    vec4 vertex;// = vec4(a_vertex,float(2400 - height), 1.0);
    if(height < 2000 || height > 2400) {
        vertex = vec4(a_vertex,0.0,1.0);
    }
    else {
        vertex = vec4(a_vertex,float(2400 - height), 1.0);
    }
    gl_Position = MVP * vertex;
    v_texCoord = a_texCoord;
    v_shadowCoord = ShadowMVP * vertex;
}