#version 450
uniform mat4 MVP;
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;
layout(location = 2) in vec4 a_col1;
layout(location = 3) in vec4 a_col2;
layout(location = 4) in vec4 a_col3;
layout(location = 5) in vec4 a_col4;

layout(location = 6) in vec4 a_p1;
layout(location = 7) in vec4 a_p2;
layout(location = 8) in vec4 a_p3;
layout(location = 9) in vec4 a_p4;
layout(location = 10) in vec4 a_p5;
layout(location = 11) in vec4 a_p6;
layout(location = 12) in vec4 a_p7;

uniform mat4 MODEL_MATRIX;
uniform float MESH_MAX_Z;

out fData
{
  vec3 normal;
  vec3 position;
} frag;

void main()
{
    // 1. Reconstruct the local per-instance transformation matrix
    mat4 a_transform = mat4(a_col1, a_col2, a_col3, a_col4);
    mat4 finalModelMatrix = MODEL_MATRIX * a_transform;

    // 2. Camera distance scaling calculation (Kept exactly from your previous code)
    vec4 instanceWorldPos = finalModelMatrix[3];
    vec4 baseClipPos = MVP * instanceWorldPos;
    float distanceToCamera = baseClipPos.w;
    float baseScaleFactor = 0.1; 
    float scaleCoef = max(distanceToCamera * baseScaleFactor, 1.0);

    // 3. Interpolation progress along the cylinder path: t ranges from 0.0 to 1.0
    float t = clamp(a_vertex.z / MESH_MAX_Z, 0.0, 1.0);

    // 4. Construct the full 8-point world-space path (explicit array size)
    vec3 pos0 = finalModelMatrix[3].xyz;
    vec3 path[8] = vec3[8](
        pos0,
        a_p1.xyz,
        a_p2.xyz,
        a_p3.xyz,
        a_p4.xyz,
        a_p5.xyz,
        a_p6.xyz,
        a_p7.xyz
    );

    // 5. Determine which segment index (0 to 6) the vertex belongs to
    float segmentProgress = t * 7.0;
    int index = int(floor(segmentProgress));
    index = clamp(index, 0, 6); 

    // Calculate fractional progress inside the targeted segment
    float segmentT = fract(segmentProgress);
    if (index == 6) {
        segmentT = clamp(segmentProgress - 6.0, 0.0, 1.0); 
    }

    // Interpolate the exact 3D world centerline position for this vertex depth
    vec3 interpolatedWorldPos = mix(path[index], path[index + 1], segmentT);

    // 6. Calculate local bending offset relative to the starting position
    // Removing pos0 isolates the bending delta vector
    vec3 worldBendingOffset = interpolatedWorldPos - pos0;

    // Project the world space bending offset back into local mesh space
    // We invert the upper 3x3 rotation/scale block of finalModelMatrix
    mat3 invModelRotScale = inverse(mat3(finalModelMatrix));
    vec3 localBendingOffset = invModelRotScale * worldBendingOffset;

    // 7. Calculate a_vertexBended by combining local scale, offset, and coordinates
    // We only offset XY so that vertex distribution along the Z axis is unaffected
    vec4 a_vertexBended = vec4(
        (a_vertex.xy * scaleCoef) + localBendingOffset.xy, 
        localBendingOffset.z, 
        1.0
    );

    // 8. Run your original matrix pipeline using a_vertexBended instead of scaledLocalVertex
    frag.position = (finalModelMatrix * a_vertexBended).xyz;
    frag.normal = normalize((finalModelMatrix * vec4(a_vertexNormal, 0.0)).xyz);
    gl_Position = MVP * finalModelMatrix * a_vertexBended;
}
