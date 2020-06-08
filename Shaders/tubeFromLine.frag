#version 150 core

in fData
{
  vec3 color;
  vec3 normal;
  vec3 position;
} frag;

uniform vec3 maincolor;
uniform vec3 eyeposition;
uniform mat4 mvp;

out vec4 fragColor;

void applyLight(const in vec3 lightDirection,
                const in vec3 worldPosition,
                const in vec3 worldNormal,
                const in float shininess,
                in out float specular,
                in out float lambertian)
{
    vec3 N = normalize(worldNormal);
    vec3 L = normalize(lightDirection);
    // Lambert's cosine law
    lambertian += max(dot(N, L), 0.0);
    if(lambertian > 0.0) {
        vec3 R = reflect(-L, N);      // Reflected light vector
        vec3 V = normalize(-worldPosition); // Vector to viewer
        // Compute the specular term
        float specAngle = max(dot(R, V), 0.0);
        specular += pow(specAngle, shininess);
    }
}

vec4 phongFunction(const in vec3 ambientColor,
                   const in vec3 diffuseColor,
                   const in vec3 specularColor,
                   const in float shininess,
                   const in vec3 worldPosition,
                   const in vec3 worldView,
                   const in vec3 worldNormal)
{
    float specular = 0.0;
    float lambertian = 0.0;
    applyLight(vec3(0.0, 0.0, 100.0) - worldPosition, worldPosition, worldNormal, shininess, specular, lambertian);
    applyLight(eyeposition - worldPosition, worldPosition, worldNormal, shininess, specular, lambertian);
    specular /= 2.0;
    lambertian /= 2.0;

    float Ka = 1.0;
    float Kd = 1.0;
    float Ks = 1.0;
    vec3 color = vec3(Ka * ambientColor +
                Kd * lambertian * diffuseColor +
                Ks * specular * specularColor);

    return vec4(color.rgb, 1.0);
}

void main()
{
    vec3 worldView = eyeposition - frag.position; // vec4(0.5 + 0.5 * frag.normal,1);
    // Lambert's cosine law
    if(gl_FrontFacing) {
        fragColor = phongFunction(maincolor, maincolor, vec3(1.0,1.0,1.0), 125.0, frag.position, worldView, frag.normal);
    } else if(length(worldView) < 300.0) {
        fragColor = phongFunction(maincolor, maincolor, vec3(1.0,1.0,1.0), 125.0, frag.position, worldView, -frag.normal);
    } else {
        discard;
    }
}
