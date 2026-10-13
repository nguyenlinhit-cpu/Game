shader_type canvas_item;
// Hiệu ứng dùng chung cho nhân vật / quái trong trận (Phase 13):
//   - outline_width > 0: viền quanh hình khi được chọn làm mục tiêu (chỉ có tác dụng với sprite có kênh alpha).
//   - flash: nháy về flash_color khi bị đánh.
//   - dissolve: tan biến theo nhiễu khi ngã (viền cháy màu dissolve_edge).

uniform vec4 outline_color : source_color = vec4(1.0, 0.84, 0.42, 1.0);
uniform float outline_width = 0.0;
uniform float flash : hint_range(0.0, 1.0) = 0.0;
uniform vec4 flash_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float dissolve : hint_range(0.0, 1.0) = 0.0;
uniform vec4 dissolve_edge : source_color = vec4(1.0, 0.65, 0.25, 1.0);
uniform float noise_scale = 0.06;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

float value_noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), u.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

void fragment() {
	vec4 c = texture(TEXTURE, UV) * COLOR;
	if (outline_width > 0.0 && c.a < 0.5) {
		vec2 px = TEXTURE_PIXEL_SIZE * outline_width;
		float a = 0.0;
		a = max(a, texture(TEXTURE, UV + vec2(px.x, 0.0)).a);
		a = max(a, texture(TEXTURE, UV - vec2(px.x, 0.0)).a);
		a = max(a, texture(TEXTURE, UV + vec2(0.0, px.y)).a);
		a = max(a, texture(TEXTURE, UV - vec2(0.0, px.y)).a);
		a = max(a, texture(TEXTURE, UV + px).a);
		a = max(a, texture(TEXTURE, UV - px).a);
		a = max(a, texture(TEXTURE, UV + vec2(px.x, -px.y)).a);
		a = max(a, texture(TEXTURE, UV + vec2(-px.x, px.y)).a);
		if (a > 0.5) {
			c = vec4(outline_color.rgb, outline_color.a * COLOR.a);
		}
	}
	c.rgb = mix(c.rgb, flash_color.rgb, flash);
	if (dissolve > 0.0) {
		// Nhiễu theo toạ độ màn hình để dùng được cả với hình tạm vẽ bằng khối (không có UV riêng).
		float n = value_noise(FRAGCOORD.xy * noise_scale) * 0.7 + value_noise(FRAGCOORD.xy * noise_scale * 3.0) * 0.3;
		if (n < dissolve) {
			discard;
		} else if (n < dissolve + 0.07) {
			c.rgb = dissolve_edge.rgb;
		}
	}
	COLOR = c;
}
