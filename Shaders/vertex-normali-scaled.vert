#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;
layout(location = 2) in mat4 a_transform;

uniform mat4 MODEL_MATRIX;

out fData
{
  vec3 normal;
  vec3 position;
} frag;

void main()
{
    // Combined Transform Matrix: Global Model Uniform * Local Per-Instance Data
    mat4 finalModelMatrix = MODEL_MATRIX * a_transform;

    // 1. Derive precise distance to camera based on the final instance world location (column 3)
    vec4 instanceWorldPos = finalModelMatrix[3];
    vec4 baseClipPos = MVP * instanceWorldPos;
    float distanceToCamera = baseClipPos.w;

    // 2. Define the scale coefficient based on camera distance
    float baseScaleFactor = 0.1; 
    float scaleCoef = max(distanceToCamera * baseScaleFactor, 1.0);

    // 3. FIX: Scale the local vertex data safely before final translation occurs.
    // This allows the `.obj` ring to expand around its own origin, keeping the tube airtight.
    vec4 scaledLocalVertex = vec4(a_vertex.xy * scaleCoef, a_vertex.z, 1.0);

    // 4. Your working layout logic, processing the isolated scaled coordinates
    frag.position = (finalModelMatrix * scaledLocalVertex).xyz;
    frag.normal = normalize((finalModelMatrix * vec4(a_vertexNormal, 0.0)).xyz);
    gl_Position = MVP * finalModelMatrix * scaledLocalVertex;
}
