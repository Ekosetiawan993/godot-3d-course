shader_type spatial;
render_mode unshaded; // no shadow

uniform vec3 color: source_color;
uniform float energy = 1.0;
uniform float alpha: hint_range(0.0, 1.0) = 0.0;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = color * energy;
	ALPHA = alpha;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
