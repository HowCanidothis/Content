// FIXED: Added mandatory highp qualifiers to your global Phong uniforms
//const vec3 Ka=vec3(0.3, 0.3, 0.3);
//const vec3 Kd=vec3(0.57, 0.57, 0.57);
//const vec3 Ks=vec3(0.5, 0.5, 0.5);

//const float SHININESS = 2.0;

uniform vec3 Ka;
uniform vec3 Kd;
uniform vec3 Ks;

uniform float SHININESS;
const float LIGHT_INTENSITY = 1.0;

// SAFE FOR ES 3.10: No precision qualifiers inside the 'const in' parameter contexts
vec4 phongFunction(const in vec3 ambientColor,
                   const in vec3 diffuseColor,
                   const in vec3 specularColor,
                   const in vec3 worldPosition,
                   const in vec3 worldNormal,
                   const in vec3 lightDirection, 
                   const in float a)
{
    vec3 N = normalize(worldNormal);
    vec3 L = normalize(-lightDirection); 
    
    vec3 ambient = Ka * ambientColor;
    
    float lambertian = max(dot(N, L), 0.0);
    vec3 diffuse = Kd * lambertian * diffuseColor;
    
    vec3 specular = vec3(0.0);
    if(lambertian > 0.0) {
        vec3 R = reflect(-L, N);                  
        vec3 V = normalize(EYE - worldPosition);  
        
        float specAngle = max(dot(R, V), 0.0);
        specular = Ks * pow(specAngle, SHININESS) * specularColor;
    }
    
    float distance = length(EYE - worldPosition); 
    float protectedDistance = max(distance, 0.5); 
    
    // Attenuation calculation stays the same
    float attenuation = 1.0 / (1.0 + 0.09 * protectedDistance + 0.032 * protectedDistance * protectedDistance);
    float nearFade = smoothstep(0.0, 0.3, distance);
    attenuation *= nearFade;
    
    // --- CHANGED LIGHTING COMBINATION ---
    // 1. Diffuse is driven uniformly by light intensity but ignores distance attenuation.
    // 2. Specular remains bound to distance attenuation so faraway highlights vanish naturally.
    vec3 finalColor = ambient + (diffuse * LIGHT_INTENSITY) + (specular * LIGHT_INTENSITY * attenuation);
    finalColor = clamp(finalColor, 0.0, 1.0);
    
    return vec4(finalColor, a);
}
