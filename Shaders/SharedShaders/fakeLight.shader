uniform float Ka = 1.0;
uniform float Kd = 0.57;
uniform float Ks = 0.5;
uniform float SHININESS = 5.0;

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
    return vec4(Ka * ambientColor +
                Kd * lambertian * diffuseColor +
                Ks * specular * specularColor, a);
}