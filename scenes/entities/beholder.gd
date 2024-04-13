extends CharacterBody3D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass


func _on_vision_timer_timeout():
	check_sight()

func check_sight():
	var overlaps = $VisionArea.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.is_in_group("player"):
				var player_position = overlap.global_transform.origin
				$VisionRayCast.look_at(player_position, Vector3.UP)
				$VisionRayCast.force_raycast_update()
				if $VisionRayCast.is_colliding():
					var collider = $VisionRayCast.get_collider()
					if collider.is_in_group("player"):
						print ("I behold you!")
					else: print("??")
