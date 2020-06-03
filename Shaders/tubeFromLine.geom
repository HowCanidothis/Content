#version 150
#extension GL_EXT_geometry_shader4 : enable

layout(lines) in;
layout(triangle_strip, max_vertices = 32) out;

out vec3 worldNormal;
out vec3 worldPosition;

uniform mat4 mvp;

vec3 createPerp(vec3 p1, vec3 p2)
{
  vec3 invec = normalize(p2 - p1);
  vec3 ret = vec3(-invec.y, invec.x, 0.0);
  if(length(ret) == 0.0) {
    ret = vec3(1.0, 0.0, 0.0);
  }
  return ret;
}
/*
// given to points p1 and p2 create a vector out
// that is perpendicular to (p2-p1)
vec3 createPerp(vec3 p1, vec3 p2)
{
  vec3 invec = normalize(p2 - p1);
  vec3 ret = cross( invec, vec3(0.0, 0.0, 1.0) );
  if ( length(ret) == 0.0 )
  {
    ret = cross( invec, vec3(0.0, 1.0, 0.0) );
  }
  return ret;
}

vec3 rotate( vec3 v, float a )
{
  float ca = cos(a); float sa = sin(a);
  float x = ca * v.x - sa*v.z;
  float z = sa * v.x + ca*v.z;
  return vec3( x, v.y, z );
}
*/
void main()
{
   float r1 = gl_PositionIn[0].w;
   float r2 = gl_PositionIn[1].w;

   vec3 axis = gl_PositionIn[1].xyz - gl_PositionIn[0].xyz;

   vec3 perpx = createPerp( gl_PositionIn[1].xyz, gl_PositionIn[0].xyz );
   vec3 perpy = cross( normalize(axis), perpx );
   int segs = 16;
   for(int i=0; i<segs; i++) {
      float a = i/float(segs-1) * 2.0 * 3.14159;
      float ca = cos(a); float sa = sin(a);
      worldNormal = vec3( ca*perpx.x + sa*perpy.x,
                     ca*perpx.y + sa*perpy.y,
                     ca*perpx.z + sa*perpy.z );

      vec3 p1 = gl_PositionIn[0].xyz + r1*worldNormal;
      vec3 p2 = gl_PositionIn[1].xyz + r2*worldNormal;
      
      gl_Position = mvp * vec4(p1, 1.0);
      worldPosition = gl_Position.xyz;
      EmitVertex();
      gl_Position = mvp * vec4(p2, 1.0);
      worldPosition = gl_Position.xyz;
      EmitVertex();
   }
   EndPrimitive();   
}
