// variables provided by g3d's vertex shader
varying vec4 worldPosition; // fragpos
varying vec3 vertexNormal;  // normal

// the model matrix comes from the camera automatically
uniform mat4 modelMatrix;

extern vec3 lightPosition;
extern float ambient = 0.0; // ambient strength, set externally, based on position
extern vec3 ambientLightColor; // ambient light color, set externally
extern vec3 lightColor; // light source color, set externally, based on position
extern vec3 viewPos;
extern float torchStrength;

float constant = 0.9f;
float linear = 0.4f;
float quadratic = 0.5f;

struct pointLight{
	vec3 position;
	vec3 color;
	float strength;
	float max_distance;
};

#define LIGHTS <LIGHTS_COUNT>
uniform pointLight pointLights[LIGHTS];

vec4 CalcPointLight(pointLight light, vec3 normal, vec3 fragPos, vec3 viewDir, vec4 texcolor, vec3 viewPos)
{

	vec3 xTangent = dFdx( viewPos.xyz );
    vec3 yTangent = dFdy( viewPos.xyz );
    vec3 faceNormal = normalize( cross( xTangent, yTangent ) );
	
	vec3 lightDir = normalize(lightPosition.xyz - worldPosition.xyz);
	vec3 halfwayDir = normalize(lightDir + viewDir);
	
	// diffuse shading
	float diffuse = light.strength * abs(dot(normal, halfwayDir));

	// specular shading
	// ABS instead of capping everything above 0 gives me nice 2-sided lighting
	float spec = pow(abs(dot(normal, halfwayDir)), 1);
	vec3 specular = lightColor * spec;

	// attenuation
	float distance = length(light.position - fragPos);
	float attenuation = light.strength/(constant+distance*linear+distance*distance*quadratic); 
	
	
	attenuation = attenuation*max(attenuation - (distance - light.max_distance),0.0) ;
	
	//float distance2 = length(light.position - viewPos);
	
	//if (distance2 > light.max_distance)
	//	attenuation = 0;
	
	
	
	diffuse *= attenuation;	
	diffuse = min (diffuse, light.strength);
	specular *= attenuation;
	return vec4((diffuse + specular)*light.color* texcolor.rgb, texcolor.a);
}

vec4 effect(vec4 color, Image tex, vec2 texcoord, vec2 pixcoord) {
	
	vec3 xTangent = dFdx( viewPos.xyz );
    vec3 yTangent = dFdy( viewPos.xyz );
    vec3 faceNormal = normalize( cross( xTangent, yTangent ) );
	
	// diffuse lighting
    vec3 norm = normalize(mat3(modelMatrix) * vertexNormal);
	vec3 lightDir = normalize(lightPosition.xyz - worldPosition.xyz);
	vec3 viewDir = normalize(viewPos.xyz - worldPosition.xyz);
	vec3 halfwayDir = normalize(lightDir + viewDir);
	
	float diff = abs(dot(norm, halfwayDir));
	vec3 diffuse = diff* lightColor;
	
	// ambient lighting
	// calculate true value of ambient color, based on strength and light source color
	vec3 ambientcolor = ambient * ambientLightColor;    
    // get color from the texture, referred as "objectColor" in the tutorial
    vec4 objectColor = Texel(tex, texcoord);
    // if this pixel is invisible, get rid of it
    if (objectColor.a == 0.0) { discard; }	
	//objectColor = vec4(objectColor.a) * objectColor + vec4(1.0 - objectColor.a) * color;

    // specular light
	float spec = pow(max(dot(norm, halfwayDir), 0.0), 8);
	vec3 specular = lightColor * spec;

    float distance = length(viewPos.xyz - worldPosition.xyz);
	float attenuation = 1/(constant+distance*linear+distance*distance*quadratic);  

	
	attenuation *= torchStrength;

	ambientcolor *= attenuation;
	diffuse *= attenuation;
	specular *= attenuation;
    
	
    // in LOVE objectColor is vec4
    vec4 result = vec4(((ambientcolor + diffuse + specular) * objectColor.rgb), objectColor.a);
	
	
    for (int i=0; i<LIGHTS; i++)
        result += CalcPointLight(pointLights[i], norm, worldPosition.xyz, viewDir, objectColor, viewPos.xyz);
	
	
	
    return vec4(result.rgb, objectColor.a);
}