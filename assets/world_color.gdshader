shader_type canvas_item;

uniform vec4 water_color = vec4(0.7,0.3,0.5,1);
uniform vec4 land_color = vec4(0.3,0.2,0.9,1);

void fragment() {
	vec4 modulator;
	vec4 col = texture(TEXTURE,UV);
	if (col.r > 0.5){
		modulator = water_color;
	} else {
		modulator = land_color;
	}
	modulator.r *= col.r;
	modulator.g *= col.g;
	modulator.b *= col.b;
	modulator.a = col.a;
	COLOR = modulator;
}