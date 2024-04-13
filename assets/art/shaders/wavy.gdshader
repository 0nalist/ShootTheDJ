shader_type canvas_item;

uniform float height = 6.9;
uniform float frequency = 17.0;
uniform float speed = 4.20;


void vertex() {
	VERTEX.y += height * sin((frequency * UV.x) + (speed * TIME/10.420));
	
	
}

void fragment() {
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
