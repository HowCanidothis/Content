#version 330 core

// Matrices and View Calculations
uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;
uniform float MESH_MAX_Z;

// Vertex Attributes (Explicitly qualified with highp)
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;
layout(location = 2) in vec3 a_texCoord; 

// Instance matrix columns (Locations 3 to 6)
layout(location = 3) in vec4 a_col1;
layout(location = 4) in vec4 a_col2;
layout(location = 5) in vec4 a_col3;
layout(location = 6) in vec4 a_col4;

// 8-point world space path points (Locations 7 to 13)
layout(location = 7) in vec4 a_p1;
layout(location = 8) in vec4 a_p2;
layout(location = 9) in vec4 a_p3;
layout(location = 10) in vec4 a_p4;
layout(location = 11) in vec4 a_p5;
layout(location = 12) in vec4 a_p6;
layout(location = 13) in vec4 a_p7;

// Flattened output attributes (No interface blocks for linking safety)
out vec3 v_fragNormal;
out vec3 v_fragPosition;
out vec3 v_fragTexCoord;

#line 1034

void main()
{
    v_fragTexCoord = a_texCoord;

    // 1. Reconstruct local transformation matrix
    mat4 a_transform = mat4(a_col1, a_col2, a_col3, a_col4);
    mat4 baseModelMatrix = MODEL_MATRIX * a_transform;

    // Extract original horizontal scaling factors safely
    float scaleX = max(length(baseModelMatrix[0].xyz), 0.0001);
    float scaleY = max(length(baseModelMatrix[1].xyz), 0.0001);

    // Calculate longitudinal progression along mesh length
    float maxZ = max(MESH_MAX_Z, 0.0001);
    float t = clamp(a_vertex.z / maxZ, 0.0, 1.0);

    vec3 pos0 = baseModelMatrix[3].xyz;
    
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

    // Determine target segment index cleanly
    float segmentProgress = t * 7.0;
    int index = int(floor(segmentProgress));
    index = clamp(index, 0, 6); 

    float segmentT = fract(segmentProgress);
    if (index == 6) {
        segmentT = clamp(segmentProgress - 6.0, 0.0, 1.0); 
    }

    // Interpolate clean world position along path centerline
    vec3 interpolatedWorldPos = mix(path[index], path[index + 1], segmentT);

    // Continuous Spline Direction Vector calculation
    vec3 dirVector = path[index + 1] - path[index];
    if (length(dirVector) < 0.0001) {
        dirVector = vec3(0.0, 0.0, 1.0);
    }
    vec3 newZ = normalize(dirVector);

    // Reconstruct stable orthogonal basis axes using base orientation references
    vec3 origX = normalize(baseModelMatrix[0].xyz);
    vec3 origY = normalize(baseModelMatrix[1].xyz);

    vec3 crossX = cross(origY, newZ);
    vec3 newX = (length(crossX) < 0.001) ? origX : normalize(crossX);
    vec3 newY = normalize(cross(newZ, newX));

    // 2. Camera distance screen scaling calculation
    vec4 instanceWorldPos = vec4(interpolatedWorldPos, 1.0);
    vec4 baseClipPos = MVP * instanceWorldPos;
    float distanceToCamera = baseClipPos.w;
    float baseScaleFactor = 0.2; 
    float scaleCoef = max(distanceToCamera * baseScaleFactor, 1.0);

    // Apply scaling configurations uniformly to the 2D cross-section slice profile
    float finalScaleX = scaleX * scaleCoef;
    float finalScaleY = scaleY * scaleCoef;

    // Reconstruct the final deformed position directly into World Space
    vec3 finalWorldPos = interpolatedWorldPos 
                       + (newX * (a_vertex.x * finalScaleX)) 
                       + (newY * (a_vertex.y * finalScaleY));

    v_fragPosition = finalWorldPos;

    // 3. AUTOMATED INVERSE-TRANSPOSE NORMAL MATRIX CALCULATION
    mat3 localSegmentMatrix = mat3(
        newX,  // Column 0: Local transformed X Axis
        newY,  // Column 1: Local transformed Y Axis
        newZ   // Column 2: Pure longitudinal spline direction vector
    );

    // Generate the perfect scale-independent Normal Matrix in true World Space
    mat3 worldNormalMatrix = transpose(inverse(localSegmentMatrix));
    
    // Transform normal into uniform World Space to sync flawlessly with fragment lighting loops
    v_fragNormal = normalize(worldNormalMatrix * a_vertexNormal);
    
    // Project directly to viewport clip space bounds
    gl_Position = MVP * vec4(finalWorldPos, 1.0);
}
