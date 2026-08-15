#version 450

uniform vec3 EYE;

#include "math.shader"
#include "phong.shader"
#line 5

in fData { vec3 normal, position, texCoord; } frag;

// --- Uniform Memory Layout Optimization ---    
uniform vec3 Ke;    uniform float Ns;  uniform float d=1.0;    
uniform int illum;  uniform float Pr;  uniform float Pm;   
uniform float Ps;   uniform float Pc;  uniform float Pcr;  

uniform float uDiffuseStrength        = 0.5;   // Приглушаем матовый цвет для глубины металла
uniform float uSaturationAdjustment   = 6.0;   
uniform float uGlowIntensity          = 1.0;   
uniform float uReflectionIntensity    = 2.5;   // Мощно выкручиваем силу отражений студии
uniform float uMetallicColorOverride  = 0.1;   // Оставляем отражения чисто белыми, без примеси цвета
uniform float uLineThickness          = 0.02;  // Делаем линии тонкими и концентрированными
uniform float uLineEdgeCrispness      = 0.75;  // Зажимаем края, чтобы полосы были чёткими и резкими
uniform float uStudioPanelIntensity   = 0.1;   // Врубаем яркость софтбоксов на максимум
uniform float uSpecularHighlightBoost = 2.0;   // Дополнительный пиковый буст для ядер бликов
uniform float uRoughnessSharpening    = 1.0;   
uniform float uMinRoughnessLimit     = 0.01;  // Максимально полируем поверхность (идеальное зеркало)
uniform float uDielectricReflectivity = 0.04;  
uniform float uStudioPanelSoftness   = 0.1;   // Делаем края софтбоксов резкими по высоте
uniform float uStudioGlintPower       = 256.0; // Сжимаем точечные искорки в микро-точки

// --- Optimized Texture Samplers & Activation Flags ---
uniform sampler2D map_Kd, map_d, map_Ke, map_Kn, map_Pr, map_Pm, map_Pmr;
uniform bool hasMapKd, hasMapD, hasMapKe, hasMapPmr, hasMapKn, hasMapPr, hasMapPm;

// --- Global Scene Configuration ---
uniform vec3 FORWARD, uLightColor = vec3(1.0), uAmbientLight = vec3(0.05, 0.05, 0.06);  
uniform float uLightIntensity = 1.0;
uniform vec4 COLOR = vec4(1.0);
uniform bool HIGHLIGHT = false;

out vec4 fragColor;
const float PI = 3.14159265359;

vec3 adjustSaturation(vec3 rgb, float adj) { 
    return mix(vec3(dot(rgb, vec3(0.2126, 0.7152, 0.0722))), rgb, adj); 
}

vec3 getZeroDerivativeNormal(vec3 n, vec2 uv) {
    vec3 mN = texture(map_Kn, uv).xyz;
    if (dot(mN, mN) < 0.0001) return n;
    mN = mN * 2.0 - 1.0;
    if (n.z < -0.99999) return normalize(mat3(vec3(0.0, -1.0, 0.0), vec3(-1.0, 0.0, 0.0), n) * mN);
    float a = 1.0 / (1.0 + n.z);
    float b = -n.x * n.y * a;
    return normalize(mat3(vec3(1.0 - n.x * n.x * a, b, -n.x), vec3(b, 1.0 - n.y * n.y * a, -n.y), n) * mN);
}

float DistributionGGX(float NdotH, float r) {
    float a2 = pow(r, 4.0);
    float dnm = (NdotH * NdotH * (a2 - 1.0) + 1.0);
    return a2 / max(PI * dnm * dnm, 0.000001);
}

float GeometrySchlickGGX(float NdotX, float r) {
    float k = pow(r + 1.0, 2.0) / 8.0;
    return NdotX / (NdotX * (1.0 - k) + k);
}

vec3 fresnelSchlick(float cosTh, vec3 F0) { 
    return F0 + (1.0 - F0) * pow(clamp(1.0 - cosTh, 0.0, 1.0), 5.0); 
}

vec3 fresnelSchlickRoughness(float cosTh, vec3 F0, float r) { 
    return F0 + (max(vec3(1.0 - r), F0) - F0) * pow(clamp(1.0 - cosTh, 0.0, 1.0), 5.0); 
}

void main() {
    if(HIGHLIGHT) {
        fragColor = COLOR;
        return;
    }
    if(illum == 0) {
        fragColor = phongFunction(uAmbientLight, COLOR.rgb, vec3(0.5), frag.position, frag.normal, FORWARD, 1.0);
        return;
    }

    vec2 uv = frag.texCoord.xy;
    float alpha = d;
    if (hasMapD) {
        alpha *= texture(map_d, uv).r;
    } else if (hasMapKd) {
        alpha *= texture(map_Kd, uv).a;
    }
    
    if ((hasMapD || alpha < 0.99) && illum != 1 && alpha < 0.15) discard;

    vec3 V = normalize(EYE - frag.position);
    vec3 N = hasMapKn ? getZeroDerivativeNormal(normalize(frag.normal), uv) : normalize(frag.normal);
    vec3 L = normalize(FORWARD);
    vec3 H = normalize(L + V);

    float NdotL = max(dot(N, L), 0.0);
    float NdotV = max(dot(N, V), 0.000001);
    float NdotH = max(dot(N, H), 0.0);
    float HdotV = max(dot(H, V), 0.0);

    vec3 baseMapColor = hasMapKd ? texture(map_Kd, uv).rgb : Kd;
    vec3 albedo = adjustSaturation(Kd * baseMapColor, uSaturationAdjustment) * uDiffuseStrength;
    
    float roughness = Pr;
    float metallic = Pm;

    if (hasMapPmr) {
        vec4 pmr = texture(map_Pmr, uv); 
        roughness = pmr.g; 
        metallic = pmr.b;
    } else {
        roughness = hasMapPr ? texture(map_Pr, uv).r : (Ns > 0.0 ? clamp(1.0 - sqrt(Ns / 1000.0), 0.0, 1.0) : Pr);
        metallic = hasMapPm ? texture(map_Pm, uv).r : (Pm < 0.001 ? 0.0 : Pm);
    }

    bool isFol = ((hasMapD || Ns > 0.0 || alpha < 0.95) && !hasMapPm && metallic < 0.01);
    if (isFol) { 
        metallic = 0.0; 
        roughness = max(roughness, 0.65); 
    }
    roughness = clamp(roughness * uRoughnessSharpening, uMinRoughnessLimit, 1.0);
    metallic = clamp(metallic, 0.0, 1.0);

    vec3 cKs = (dot(Ks, Ks) < 0.0001) ? vec3(1.0) : Ks;
    vec3 cKa = (dot(Ka, Ka) < 0.0001) ? vec3(1.0) : Ka;
    
    float f0MixWeight = metallic;
    if (!isFol && roughness < 0.4) {
        f0MixWeight = max(metallic, 0.5);
    }
    vec3 F0 = mix(vec3(uDielectricReflectivity), albedo, f0MixWeight);
    
    int actIllum = (hasMapPmr || hasMapPm || metallic > 0.01) ? 2 : illum;
    if (actIllum == 0) { 
        fragColor = vec4(albedo + (Ke * uGlowIntensity), alpha); 
        return; 
    }

    // --- DIRECT LIGHT ENGINE ---
    vec3 F = fresnelSchlick(HdotV, F0) * cKs;
    vec3 kS = F;
    vec3 kD = (vec3(1.0) - kS) * (1.0 - metallic);
    
    vec3 pSpec = vec3(0.0);
    if (actIllum >= 2) {
        float specNum = DistributionGGX(NdotH, roughness) * GeometrySchlickGGX(NdotV, roughness) * GeometrySchlickGGX(NdotL, roughness);
        vec3 specValue = (specNum * F * uSpecularHighlightBoost * uReflectionIntensity) / max(4.0 * NdotV, 0.001);
        pSpec = specValue * (isFol ? 0.05 : 1.0); 
    }

    vec3 direct = vec3(0.0);
    if (actIllum == 1) {
        direct = (albedo / PI) * NdotL * uLightColor * uLightIntensity;
    } else {
        vec3 diffuseBRDF = kD * albedo / PI; 
        direct = (diffuseBRDF * NdotL + pSpec) * uLightColor * uLightIntensity;
    }

    // =========================================================================
    // 5. МНОГОЛИНЕЙНЫЙ БАНК С ПЕРСПЕКТИВНЫМ СЖАТИЕМ К КРАЯМ ЦИЛИНДРА
    // =========================================================================
    vec3 R = reflect(-V, N);
    
    // Вычисляем стабильную мировую ось трубы по UV-шагу меша
    vec3 dPdx = dFdx(frag.position);
    vec3 dPdy = dFdy(frag.position);
    vec2 dTdx = dFdx(uv);
    vec2 dTdy = dFdy(uv);
    vec3 tubeAxis = normalize(dPdx * dTdy.y - dPdy * dTdx.y);
    if (length(tubeAxis) < 0.001) tubeAxis = vec3(0.0, 1.0, 0.0);
    
    vec3 tubeNormalTangent = normalize(cross(N, tubeAxis));
    float rawHorizon = dot(R, tubeNormalTangent); // Вектор в диапазоне [-1.0, 1.0]

    // ИСПРАВЛЕНИЕ ДЛЯ ИСКАЖЕНИЯ СИЛУЭТА (Перспективное сжатие):
    // Арксинус преобразует линейный шаг в сферический. Это заставит отраженные 
    // полосы света плавно сжиматься в плотные изящные линии у краев цилиндра,
    // в точности воссоздавая оптический эффект с эталонного рендера!
    float horizonSpace = asin(clamp(rawHorizon, -0.99, 0.99)) / PI + 0.5;

    // Вычисляем ширину и спад краев напрямую из UI параметров
    float edgeBlurWidth = max((1.0 - uLineEdgeCrispness) * 0.25, 0.001);
    float halfWidth = max(uLineThickness * 0.5, 0.001);

    float inverseMask = 1.0;
    
    if (!isFol) {
        // Калиброванная сетка студийных ламп (сбалансированное распределение по сфере)
        // Структура: vec3(Центр_Лампы, Множитель_Ширины, Интенсивность_Вклада)
        vec3 lights[6] = vec3[6](
            vec3(0.20, 0.6, 0.40), // Левый изящный контур-блик (уже сильно сжат физикой)
            vec3(0.35, 1.1, 0.90), // Основной левый софтбокс
            vec3(0.46, 0.3, 0.45), // Тонкий центральный разделительный блик
            vec3(0.54, 0.3, 0.45), // Вторичный центральный акцент
            vec3(0.65, 1.1, 0.90), // Основной правый софтбокс
            vec3(0.80, 0.6, 0.40)  // Правый изящный контур-блик
        );

        for (int i = 0; i < 6; i++) {
            float c = lights[i].x; 
            float w = halfWidth * lights[i].y; 
            float b = edgeBlurWidth * lights[i].y; 
            float intensity = lights[i].z; 
            
            float lineValue = smoothstep(c - w - b, c - w, horizonSpace) * 
                              (1.0 - smoothstep(c + w, c + w + b, horizonSpace));
                              
            // Screen Blend блендинг для идеальных полутонов
            inverseMask *= (1.0 - lineValue * intensity);
        }
    }
    
    float maskLines = isFol ? 0.2 : (1.0 - inverseMask);
    
    // Мягкое продольное затухание студийной панели к краям трубы
    float softCeilingBox = smoothstep(-uStudioPanelSoftness, uStudioPanelSoftness, abs(dot(R, tubeAxis)));
    
    vec3 baseBg = max(uAmbientLight * 1.5, vec3(0.05));
    vec3 brightPanelColor = vec3(1.9, 1.9, 2.0) * uStudioPanelIntensity * uReflectionIntensity;
    
    // Контрастный микс студийного градиента
    vec3 studio = mix(baseBg, brightPanelColor, maskLines) * (1.0 - softCeilingBox * 0.3);
    
    // Анизотропные блики по шпинделю
    if (!isFol) {
        float glintA = pow(max(dot(R, normalize(tubeAxis + tubeNormalTangent * 0.2)), 0.0), uStudioGlintPower);
        float glintB = pow(max(dot(R, normalize(tubeAxis - tubeNormalTangent * 0.2)), 0.0), uStudioGlintPower);
        studio += (glintA + glintB) * (1.5 * uStudioPanelIntensity * uReflectionIntensity * (1.0 - roughness));
    }

    vec3 F_amb = fresnelSchlickRoughness(NdotV, F0, roughness) * cKs;
    vec3 kD_amb = (vec3(1.0) - F_amb) * (1.0 - metallic); 

    float specMask = (isFol || actIllum == 1) ? 0.0 : 1.0;
    vec3 envSpec = studio * F_amb * (1.0 - roughness) * specMask;
    
    // Боковой зеркальный ободок Френеля по краям силуэта
    if (!isFol && actIllum >= 2) {
        float grazingRim = pow(clamp(1.0 - NdotV, 0.0, 1.0), 3.5) * (1.0 - roughness);
        envSpec += brightPanelColor * grazingRim * uReflectionIntensity * 0.5;
    }

    vec3 envDiffBase = uAmbientLight * albedo * kD_amb * cKa * 1.5;
    float wrapAmbient = max(dot(N, L) * 0.5 + 0.5, 0.0);
    vec3 foliageScattering = uAmbientLight * 0.4 * vec3(0.8, 0.9, 1.0) * wrapAmbient;
    vec3 envDiff = envDiffBase + (isFol ? foliageScattering : vec3(0.0));

    vec3 ambientComponent = (envDiff * pow(NdotV, 0.9)) + envSpec;

    // 6. EMISSIVE & GLOW
    vec3 emissive = Ke * uGlowIntensity;
    if (hasMapKe) {
        emissive += texture(map_Ke, uv).rgb * uGlowIntensity;
    }

    // 7. COMPOSITING
    vec3 extraMetalBounce = (actIllum >= 2) ? albedo * metallic * baseBg * F_amb : vec3(0.0);
    vec3 finalRGB = ambientComponent + direct + emissive + extraMetalBounce;
    
    // ACES Tone Mapping
    vec3 mappedRGB = finalRGB * (1.0 + finalRGB * 0.15) / (finalRGB + 1.0);
    fragColor = vec4(pow(max(mappedRGB, vec3(0.0)), vec3(1.0 / 2.2)), alpha);
}

