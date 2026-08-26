uniform vec3 Ka;
uniform vec3 Kd;
uniform vec3 Ks;
uniform float SHININESS; // Remember to initialize this via C++ (e.g., 5.0f)

vec4 phongFunction(const in vec3 ambientColor,
                   const in vec3 diffuseColor,
                   const in vec3 specularColor,
                   const in vec3 worldPosition,
                   const in vec3 worldNormal,
                   const in vec3 lightDirection,
                   const in float a)
{
    vec3 N = normalize(worldNormal);
    vec3 L = normalize(lightDirection);
    
    // Lambert's cosine law
    float lambertian = max(-dot(N, L), 0.0);
    float specular = 0.0;
    
    if(lambertian > 0.0) {
        vec3 R = reflect(L, N);      // Reflected light vector
        vec3 V = normalize(L);
        float specAngle = max(-dot(R, V), 0.0);
        specular = pow(specAngle, SHININESS);
    }
    
    // Component multiplication now utilizes full vector math across channels
    return vec4(Ka * ambientColor +
                Kd * lambertian * diffuseColor +
                Ks * specular * specularColor, a);
}