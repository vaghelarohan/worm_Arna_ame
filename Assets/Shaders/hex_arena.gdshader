shader_type spatial;
render_mode diffuse_burley, specular_schlick_ggx;

// Rich Royal Blue Arena Palette (matching Worms Zone / reference image)
uniform vec4 hex_bg : source_color = vec4(0.045, 0.085, 0.185, 1.0);     // #0b162f Deep sapphire/navy
uniform vec4 hex_center : source_color = vec4(0.085, 0.165, 0.320, 1.0); // #162a52 Royal blue tile center
uniform vec4 hex_bevel : source_color = vec4(0.130, 0.240, 0.440, 1.0);  // #213d70 Soft beveled highlight
uniform vec4 hex_border : source_color = vec4(0.065, 0.135, 0.270, 1.0); // #102245 Outer border
uniform vec4 hex_seam : source_color = vec4(0.025, 0.050, 0.120, 1.0);   // #060d1f Deep seam gap

// Standard hexagonal distance function
float hex_dist(vec2 p) {
	p = abs(p);
	return max(dot(p, vec2(0.8660254, 0.5)), p.y);
}

vec4 get_hex(vec2 p) {
	vec2 s = vec2(1.7320508, 1.0);
	vec2 h = s * 0.5;
	vec2 a = mod(p, s) - h;
	vec2 b = mod(p - h, s) - h;
	vec2 g = dot(a, a) < dot(b, b) ? a : b;
	vec2 id = p - g;
	float d = hex_dist(g);
	return vec4(g, d, length(id));
}

void fragment() {
	// Equilateral hex grid scaling
	vec2 uv = UV * 48.0;
	vec4 h = get_hex(uv);
	float d = h.z; // distance from center of hexagon (max is 0.5 at edges)
	float norm_d = clamp(d / 0.50, 0.0, 1.0);
	
	// Pseudo-random subtle variation between tiles for organic 3D look
	float tile_seed = fract(sin(dot(floor(uv - h.xy + vec2(0.1, 0.3)), vec2(12.9898, 78.233))) * 43758.5453);
	float subtle_tint = (tile_seed - 0.5) * 0.025;
	
	// 1. Center radial dome lighting (soft gradient)
	vec3 col = mix(hex_center.rgb + subtle_tint, hex_bg.rgb + subtle_tint, smoothstep(0.0, 0.78, norm_d));
	
	// 2. Beveled highlight edge (3D tile bevel)
	float bevel = smoothstep(0.78, 0.88, norm_d) * (1.0 - smoothstep(0.88, 0.94, norm_d));
	col = mix(col, hex_bevel.rgb, bevel * 0.65);
	
	// 3. Dark tile perimeter border
	float border = smoothstep(0.88, 0.95, norm_d);
	col = mix(col, hex_border.rgb, border * 0.85);
	
	// 4. Recessed seam between adjacent tiles
	float seam = smoothstep(0.95, 1.0, norm_d);
	col = mix(col, hex_seam.rgb, seam * 0.95);
	
	// Subtle glossy surface
	ALBEDO = col;
	ROUGHNESS = 0.22;
	SPECULAR = 0.60;
	METALLIC = 0.06;
}
