shader_type canvas_item;

// Color Swap Shader
// Replaces a specific color (mask_color) with a target color (shirt_color).

uniform vec4 shirt_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform vec4 mask_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // Red is default mask
uniform float tolerance : hint_range(0.0, 1.0) = 0.15;

void fragment() {
	vec4 curr_color = texture(TEXTURE, UV);
	
	// Check distance to mask color
	if (distance(curr_color.rgb, mask_color.rgb) < tolerance) {
		// Preserve original alpha and shading (multiply?)
		// Simple replacement:
		COLOR = vec4(shirt_color.rgb, curr_color.a);
		
		// Advanced: Preserve luminance could come here
	} else {
		COLOR = curr_color;
	}
}
