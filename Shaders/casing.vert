#version 150 core

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

in vec3 position;        // 1. Position      (float, 3)
in vec3 normal;          // 2. Normal        (float, 3)
in vec4 color;           // 3. Color         (float, 4)
in float t;              // 4. T             (float, 1)
in int applyLight;       // 5. ApplyLight    (qint32, 1)
in vec3 extrusionNormal; // 6. ExtrusionNormal from the very end of meshBuilder

out fData
{
  vec3 normal;
  vec3 position;
  vec4 color;
  float t;
  flat bool applyLight;
} frag;

void main()
{
  // 1. Calculate the correct position in Clip Space to derive honest W depth
  // Multiply MVP exactly once with the base local position vector
  vec4 baseClipPos = MVP * vec4(position, 1.0);
  float distanceToCamera = baseClipPos.w;
  
  // 2. Base scale factor to define the extrusion outline thickness
  // (0.015 means expanding outward by 1.5% of the total camera depth)
  float baseScaleFactor = 0.015; 
   
  // 4. Calculate the expansion offset strictly within local coordinate space
  // Since extrusionNormal is already a normalized cross-section unit vector from C++,
  // this provides an distortion-free outward radial shift.
  vec3 localOffset = extrusionNormal * distanceToCamera * baseScaleFactor;
  vec3 extrudedLocalPosition = position + localOffset;
  
  // 5. Final projection matrix multiplication executed exactly once 
  gl_Position = MVP * vec4(extrudedLocalPosition, 1.0);
  
  // 6. Forward clean, uncorrupted vertex positional data down the rendering pipeline
  vec4 worldPos = MODEL_MATRIX * vec4(extrudedLocalPosition, 1.0);
  frag.position = worldPos.xyz;
  frag.normal = normalize(mat3(MODEL_MATRIX) * normal);
  frag.t = t;
  frag.color = color;
  frag.applyLight = bool(applyLight);
}
