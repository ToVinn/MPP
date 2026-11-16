shader_type canvas_item;

// Dither Transparency & Camera Occlusion Shader for Echoes of Astra
// Provides authentic pixel-art Bayer matrix dithering and smooth opacity fading

uniform float dither_amount : hint_range(0.0, 1.0) = 0.0;
uniform float alpha_mult : hint_range(0.0, 1.0) = 1.0;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	if (tex_color.a < 0.05) {
		discard;
	}
	
	// 4x4 Bayer Matrix in screen space
	int x = int(mod(FRAGCOORD.x, 4.0));
	int y = int(mod(FRAGCOORD.y, 4.0));
	int index = y * 4 + x;
	
	float dither_val = 0.0;
	if (index == 0) dither_val = 0.0625;
	else if (index == 1) dither_val = 0.5625;
	else if (index == 2) dither_val = 0.1875;
	else if (index == 3) dither_val = 0.6875;
	else if (index == 4) dither_val = 0.8125;
	else if (index == 5) dither_val = 0.3125;
	else if (index == 6) dither_val = 0.9375;
	else if (index == 7) dither_val = 0.4375;
	else if (index == 8) dither_val = 0.25;
	else if (index == 9) dither_val = 0.75;
	else if (index == 10) dither_val = 0.125;
	else if (index == 11) dither_val = 0.625;
	else if (index == 12) dither_val = 1.0;
	else if (index == 13) dither_val = 0.5;
	else if (index == 14) dither_val = 0.875;
	else dither_val = 0.375;
	
	// Screen-door dither transparency
	if (dither_amount > 0.0 && dither_val <= dither_amount) {
		discard;
	}
	
	COLOR = tex_color * COLOR;
	COLOR.a *= alpha_mult;
}

