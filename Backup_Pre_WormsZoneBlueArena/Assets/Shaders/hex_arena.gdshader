shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

uniform vec4 dark_navy : source_color = vec4(0.04, 0.065, 0.13, 1.0);  // #0a1121
uniform vec4 tile_inner : source_color = vec4(0.075, 0.12, 0.23, 1.0); // #131f3b
uniform vec4 hex_line : source_color = vec4(0.12, 0.20, 0.38, 1.0);    // #1f3361

vec4 hex_grid(vec2 p) {
	const vec2 s = vec2(1.0, 1.7320508);
	const vec2 h = s * 0.5;
	
	vec2 a = mod(p, s) - h;
	vec2 b = mod(p - h, s) - h;
	vec2 g = dot(a, a) < dot(b, b) ? a : b;
	vec2 id = p - g;
	
	vec2 abs_g = abs(g);
	float d = max(dot(abs_g, vec2(0.8660254, 0.5)), abs_g.y);
	return vec4(g, d, length(id));
}

void fragment() {
	vec2 uv = UV * 65.0;
	vec4 h = hex_grid(uv);
	float d = h.z;
	float norm_d = clamp(d / 0.4330127, 0.0, 1.0);
	
	// Subtle pseudo-random variation per tile
	float rand_tile = fract(sin(dot(floor(uv - h.xy), vec2(12.9898, 78.233))) * 43758.5453);
	
	// Radial tile gradient: light in center, deep navy at edges
	vec3 col = mix(tile_inner.rgb, dark_navy.rgb, smoothstep(0.10, 0.85, norm_d));
	col += (rand_tile - 0.5) * 0.015;
	
	// Subtle beveled border line (dark blue)
	float border = smoothstep(0.85, 0.95, norm_d);
	col = mix(col, hex_line.rgb, border * 0.7);
	
	// Deep navy seam line between tiles
	float seam = smoothstep(0.95, 1.0, norm_d);
	col = mix(col, dark_navy.rgb * 0.35, seam);
	
	ALBEDO = col;
	ROUGHNESS = 0.28;
	SPECULAR = 0.55;
	METALLIC = 0.10;
}
