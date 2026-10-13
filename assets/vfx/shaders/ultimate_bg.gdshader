shader_type canvas_item;
// Nền khi dùng Tuyệt kỹ (Phase 13): phủ màu nguyên tố, tia sáng xoay từ tâm, tối dần ra mép.
// strength 0 → 1 do màn trận tween khi bắt đầu / kết thúc Tuyệt kỹ.

uniform vec4 tint : source_color = vec4(1.0, 0.6, 0.3, 1.0);
uniform float strength : hint_range(0.0, 1.0) = 0.0;
uniform float ray_count = 22.0;

void fragment() {
	vec2 uv = UV - vec2(0.5);
	uv.x *= 1.78;
	float angle = atan(uv.y, uv.x);
	float rays = smoothstep(0.55, 1.0, sin(angle * ray_count + TIME * 5.0));
	float dist = length(uv);
	vec3 base = mix(tint.rgb * 0.25, tint.rgb * 0.6, smoothstep(0.9, 0.0, dist));
	vec3 col = base + tint.rgb * rays * 0.45 * smoothstep(0.05, 0.6, dist);
	COLOR = vec4(col, strength * (0.55 + 0.35 * clamp(dist * 1.3, 0.0, 1.0)));
}
