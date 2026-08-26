#version 330 core

// Uniforms with explicit precision tracking
uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

// Vertex Attributes
layout(location = 0) in vec3 position;        
layout(location = 1) in vec3 normal;          
layout(location = 2) in vec4 color;           
layout(location = 3) in float t;              
layout(location = 4) in int applyLight;       
layout(location = 5) in vec3 extrusionNormal; 

// Flattened output variables matching fragment shader inputs exactly
out vec3 v_fragNormal;
out vec3 v_fragPosition;
out vec4 v_fragColor;
out float v_fragT;
flat out int v_fragApplyLight; // Forwarded as int/uint for cross-driver linking safety

void main()
{
    // 1. Calculate the correct position in Clip Space to derive honest W depth
    vec4 baseClipPos = MVP * vec4(position, 1.0);
    float distanceToCamera = baseClipPos.w;
  
    // 2. Base scale factor to define the extrusion outline thickness
    float baseScaleFactor = 0.1; 
   
    // 4. Calculate the expansion offset strictly within local coordinate space
    vec3 localOffset = extrusionNormal * distanceToCamera * baseScaleFactor;
    vec3 extrudedLocalPosition = position + localOffset;
  
    // 5. Final projection matrix multiplication executed exactly once 
    gl_Position = MVP * vec4(extrudedLocalPosition, 1.0);
  
    // 6. Forward clean, uncorrupted vertex positional data down the rendering pipeline
    vec4 worldPos = MODEL_MATRIX * vec4(extrudedLocalPosition, 1.0);
    v_fragPosition = worldPos.xyz;
    v_fragNormal = normalize(mat3(MODEL_MATRIX) * normal);
    v_fragT = t;
    v_fragColor = color;
    
    // Pass integer status directly down the line (1 for true, 0 for false)
    v_fragApplyLight = applyLight;
}
