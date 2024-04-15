shader_type spatial;

uniform vec3 character_position;
uniform float fade_distance;

varying vec3 world_vertex;

uniform vec4 color : source_color = vec4(0.94, 0.54, 0.15, 1.0);
void vertex() {
	world_vertex = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
// Calculate the distance between the fragment and the character
	float chardistance = length(character_position - world_vertex);
    
// Calculate the alpha value based on the distance
	float alpha = 1.0 - smoothstep(0.0, fade_distance, chardistance);
	ALBEDO = color.rgb;
	ALPHA = alpha;
// Discard the fragment if the alpha is zero
	if (alpha <= 0.0) {
		discard;
	}
}