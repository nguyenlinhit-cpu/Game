shader_type canvas_item;
// Nền tạm cho màn tiêu đề / lời dẫn: trời đêm, sao nhấp nháy và quầng sáng Tâm Thần Nhãn.

uniform vec4 top_color : source_color = vec4(0.02, 0.03, 0.08, 1.0);
uniform vec4 bottom_color : source_color = vec4(0.09, 0.05, 0.17, 1.0);
uniform vec4 glow_color : source_color = vec4(0.95, 0.84, 0.54, 1.0);
uniform vec2 glow_center = vec2(0.5, 0.42);
uniform float glow_strength = 0.35;
uniform float star_density = 90.0;
uniform float aspect = 1.7778;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec3 col = mix(top_color.rgb, bottom_color.rgb, UV.y);

	vec2 grid = UV * vec2(star_density * aspect, star_density);
	vec2 cell = floor(grid);
	vec2 local = fract(grid) - 0.5;
	float h = hash(cell);
	vec2 offset = vec2(hash(cell + 1.3), hash(cell + 7.1)) - 0.5;
	float dist = length(local - offset * 0.6);
	float twinkle = 0.55 + 0.45 * sin(TIME * (1.0 + h * 3.0) + h * 40.0);
	float star = step(0.965, h) * smoothstep(0.14, 0.0, dist) * twinkle;
	col += vec3(star);

	vec2 d = (UV - glow_center) * vec2(aspect, 1.0);
	float glow = exp(-dot(d, d) * 16.0) * glow_strength * (0.85 + 0.15 * sin(TIME * 1.3));
	col += glow_color.rgb * glow;

	COLOR = vec4(col, 1.0);
}
