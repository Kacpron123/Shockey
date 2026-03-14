shader_type canvas_item;

uniform sampler2D screen_texture: hint_screen_texture, repeat_disable, filter_linear; 
uniform vec3 first_color: source_color= vec3(1,1,1);
uniform vec3 second_color: source_color = vec3(0,0,0);


void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	float t = step(0.5, dot(color, vec3(0.299, 0.587, 0.114)));

	COLOR.rgb = mix(second_color, first_color, t);
	COLOR.a = 1.0;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
