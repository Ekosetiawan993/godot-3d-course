shader_type spatial;
render_mode cull_disabled;

uniform vec3 color: source_color;
uniform vec3 shadow_color: source_color;
uniform sampler2D curve_sampler: repeat_disable; // curve of the leave
uniform sampler2D wind_sampler: repeat_enable, filter_linear;
uniform float wind_strength = 0.5;
global uniform vec3 player_position;


void vertex() {
	// Called for every vertex the material is visible on.
	// wind
	vec2 world_pos = vec2(NODE_POSITION_WORLD.x, NODE_POSITION_WORLD.z); // position of grass
	float curve = texture(curve_sampler, vec2(UV.y, 0.0)).x; // get curve, target the value by uv y 
	//VERTEX += vec3(curve);
	// 9:38 wind
	// take wind_sampler, use world_pos to get value from sampler noise pic
	// * TIME to move the world_pos, -0.5 to make the swing left-right
	float wind = (texture(wind_sampler, world_pos * 0.08 + TIME * 0.05).x - 0.5) * curve;
	vec3 wind_displacement = vec3(wind) * wind_strength * (1.0 - UV.y);
	//VERTEX += vec3(wind);
	VERTEX += wind_displacement;
	
	// 9:41 player displacement, set global shader parameter, project - project settings
	vec3 direction_to_player = player_position - NODE_POSITION_WORLD;
	float distance_to_player = length(direction_to_player);
	// check player is close enough
	float falloff = 1.0 - smoothstep(0.0, 1.0, distance_to_player); // close = 1, far away = 0
	//VERTEX += -direction_to_player * falloff;
	VERTEX += -direction_to_player * falloff * curve * 2.0;
}

void fragment() {
	ALBEDO = mix(color, shadow_color * color, UV.y);
	// Called for every pixel the material is visible on.
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
