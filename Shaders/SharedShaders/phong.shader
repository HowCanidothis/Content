void applyLight(const in vec3 lightDirection,
                const in vec3 worldPosition,
                const in vec3 worldNormal,
                const in float shininess,
                inout float specular,
                inout float lambertian)
{
    vec3 N = normalize(worldNormal);
    vec3 L = normalize(lightDirection);
    // Lambert's cosine law
    lambertian += max(-dot(N, L), 0.0);
    if(lambertian > 0.0) {
        vec3 R = reflect(L, N);      // Reflected light vector
        vec3 V = L; // Vector to viewer
        // Compute the specular term
        float specAngle = max(-dot(R, V), 0.0);
        float intensity = length(worldPosition - EYE)  / SCALE;
        specular += pow(specAngle / intensity * 50.0, shininess);
    }
}

vec4 phongFunction(const in vec3 ambientColor,
                   const in vec4 diffuseColor,
                   const in vec3 specularColor,
                   const in float shininess,
                   const in vec3 worldPosition,
                   const in vec3 worldNormal,
                   const in vec3 forward)
{
    float specular = 0.0;
    float lambertian = 1.0;
    //applyLight(vec3(0.0, 0.0, 1.0), worldPosition, worldNormal, shininess, specular, lambertian);
    applyLight(forward, worldPosition, worldNormal, shininess, specular, lambertian);
    specular /= 1.0;
    lambertian /= 1.0;

    float Ka = 1.0;
    float Kd = 0.57;
    float Ks = 1.0;
    vec3 color = vec3(Ka * ambientColor +
                Kd * lambertian * diffuseColor.rgb +
                Ks * specular * specularColor);

    return vec4(color.rgb, diffuseColor.a);
}
