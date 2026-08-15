#version 450

uniform mat4 MVP;
uniform mat4 MODEL_MATRIX;

// Vertex Attributes - Order matches your C++ VBO layout packing
layout(location = 0) in vec3 a_vertex;
layout(location = 1) in vec3 a_vertexNormal;
layout(location = 2) in vec3 a_texCoord; 

// Interface Output Block (Syncs flawlessly with your Fragment input block)
out fData
{
    vec3 normal;
    vec3 position;
    vec3 texCoord;
} frag;

void main()
{
    // 1. Pass texture coordinates directly to the fragment stage
    frag.texCoord = a_texCoord;

    // 2. Transform vertex position into true World Space using the Model matrix
    frag.position = (MODEL_MATRIX * vec4(a_vertex, 1.0)).xyz;

    // 3. DYNAMIC WORLD-SPACE NORMAL TRANSFORMATION
    // Extracts the upper-left 3x3 of the MODEL_MATRIX and calculates its inverse-transpose.
    // This scales and rotates the vector without distortion from model scale factors.
    mat3 worldNormalMatrix = transpose(inverse(mat3(MODEL_MATRIX)));
    frag.normal = normalize(worldNormalMatrix * a_vertexNormal);

    // 4. Output final clip space projection bounds positioning vector
    gl_Position = MVP * vec4(frag.position, 1.0);
}
