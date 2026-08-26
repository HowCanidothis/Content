#version 330 core

// 1. Uniform Matrices and View Calculations with qualifiers
uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

// 2. Vertex Attributes matching your C++ VBO layout packing
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;
layout(location = 2) in vec3 a_texCoord; 

// 3. Flattened standalone output variables (No interface block for linking safety)
out vec3 v_fragNormal;
out vec3 v_fragPosition;
out vec3 v_fragTexCoord;

void main()
{
    // 1. Pass texture coordinates directly to the fragment stage
    v_fragTexCoord = a_texCoord;

    // 2. Transform vertex position into true World Space using the Model matrix
    v_fragPosition = (MODEL_MATRIX * vec4(a_vertex, 1.0)).xyz;

    // 3. DYNAMIC WORLD-SPACE NORMAL TRANSFORMATION
    // Extracts the upper-left 3x3 of the MODEL_MATRIX and calculates its inverse-transpose.
    // This scales and rotates the vector without distortion from model scale factors.
    mat3 worldNormalMatrix = transpose(inverse(mat3(MODEL_MATRIX)));
    v_fragNormal = normalize(worldNormalMatrix * a_vertexNormal);

    // 4. Output final clip space projection bounds positioning vector
    // Using v_fragPosition directly prevents redundant matrix recalculation
    gl_Position = MVP * vec4(v_fragPosition, 1.0);
}
