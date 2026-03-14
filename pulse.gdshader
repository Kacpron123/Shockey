shader_type canvas_item;

uniform vec3 pulse_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float thickness: hint_range(0.01, 0.5) = 0.05; // Grubość pierścienia
uniform float effect_intensity: hint_range(-1.0, 2.0) = 0.0; // To kontroluje promień fali
void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
    vec2 uv = UV - 0.5;
    
    float dist = length(uv);
    
    float edge = abs(dist - (effect_intensity * 0.5));
    float mask = step(edge, thickness); 
    
    vec3 final_rgb = mix(vec3(0,0,0), tex_color.rgb, mask);
    
    COLOR = vec4(final_rgb, tex_color.a);
}