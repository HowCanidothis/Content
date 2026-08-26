#version 330 core

layout(lines) in;
layout(triangle_strip, max_vertices = 32) out;

// Flattened inputs matching your vertex shader output
in vec4 v_vertexPos[];

// Corrected outputs matching your fragment shader inputs
out vec3 v_fragNormal;
out vec3 v_fragPosition;

uniform mat4 MODEL_MATRIX;
uniform vec3 EYE;
uniform mat4 MVP;

vec3 createPerp(vec3 p1, vec3 p2)
{
  vec3 invec = normalize(p2 - p1);
  vec3 ret = vec3(-invec.y, invec.x, 0.0);
  if(length(ret) == 0.0) {
    ret = vec3(1.0, 0.0, 0.0);
  }
  return ret;
}

void main()
{
   // Array indexing to pull vertex components correctly
   vec3 pos1 = (MODEL_MATRIX * vec4(v_vertexPos[0].xyz, 1.0)).xyz;
   vec3 pos2 = (MODEL_MATRIX * vec4(v_vertexPos[1].xyz, 1.0)).xyz;

   vec3 axis = pos2 - pos1;
   vec3 toEye = EYE - pos1;

   if(length(toEye) > 3000.0 && length(EYE - pos2) > 3000.0) {
      EndPrimitive();
      return;
   }

   vec3 projectedToEye = pos1 + axis * dot(toEye, axis) / dot(axis, axis);
   float distanceToFragment = length(EYE - projectedToEye);

   if(distanceToFragment > 2000.0) {
       EndPrimitive();
       return;
   }

   float r1 = 1.0;
   float r2 = 1.0;

   // FIXED: Corrected reference point tracking order to keep normals outward-facing
   vec3 perpx = createPerp( pos1, pos2 );
   vec3 perpy = cross( normalize(axis), perpx );
   int segs = 16;
   for(int i=0; i<segs; i++) {
      // FIXED: Added explicit float cast to resolve implicit type-casting errors
      float a = float(i) / float(segs-1) * 2.0 * 3.14159;
      float ca = cos(a); float sa = sin(a);
      vec3 worldNormal = normalize(vec3( ca*perpx.x + sa*perpy.x,
                     ca*perpx.y + sa*perpy.y,
                     ca*perpx.z + sa*perpy.z ));

      vec3 p1 = pos1 + r1*worldNormal;
      vec3 p2 = pos2 + r2*worldNormal;

      // Vertex 1
      vec4 transformedPoint = vec4(p1, 1.0);
      gl_Position = MVP * transformedPoint;
      v_fragNormal = worldNormal;
      v_fragPosition = transformedPoint.xyz;
      EmitVertex();
      
      // Vertex 2
      transformedPoint = vec4(p2, 1.0);
      gl_Position = MVP * transformedPoint;
      v_fragNormal = worldNormal; 
      v_fragPosition = transformedPoint.xyz;
      EmitVertex();
   }
   EndPrimitive();   
}
