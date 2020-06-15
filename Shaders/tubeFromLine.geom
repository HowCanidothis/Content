#version 150
#extension GL_EXT_geometry_shader4 : enable

layout(lines) in;
layout(triangle_strip, max_vertices = 32) out;

in vData
{
  vec4 position;
} vertices[];

out fData
{
  vec3 normal;
  vec3 position;
} frag;

uniform mat4 mvp;
uniform mat4 invertedMvp;

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
   float r1 = vertices[0].position.w;
   float r2 = vertices[1].position.w;

   //mat4 normalMatrix = transpose(inverse(mvp));

   vec3 axis = vertices[1].position.xyz - vertices[0].position.xyz;

   vec3 perpx = createPerp( vertices[1].position.xyz, vertices[0].position.xyz );
   vec3 perpy = cross( normalize(axis), perpx );
   int segs = 16;
   for(int i=0; i<segs; i++) {
      float a = i/float(segs-1) * 2.0 * 3.14159;
      float ca = cos(a); float sa = sin(a);
      vec3 worldNormal = normalize(vec3( ca*perpx.x + sa*perpy.x,
                     ca*perpx.y + sa*perpy.y,
                     ca*perpx.z + sa*perpy.z ));

      vec3 p1 = vertices[0].position.xyz + r1*worldNormal;
      vec3 p2 = vertices[1].position.xyz + r2*worldNormal;
      
      //vec4 normalInterp = normalMatrix * vec4(worldNormal, 0.0));

      gl_Position = mvp * vec4(p1, 1.0);
      frag.normal = worldNormal;
      frag.position = p1;
      EmitVertex();
      gl_Position = mvp * vec4(p2, 1.0);
      frag.position = p2;
      EmitVertex();
   }
   EndPrimitive();   
}
