extends SubViewport

var screen_size: Vector2
# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	size = screen_size



