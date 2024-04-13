extends Marker3D


#### TOTALLY BROKEN. "Invalid set index 'postion' (on base: 'Marker3D') with value of type 'Vector3'."


#@export var damage_node: PackedScene


'''
func spawn_damage_number(damage_amount: int, position: Vector3):
	var damage_number_scene = load("res://scenes/hit_number.tscn")
	if damage_number_scene:
		var damage_number_instance = damage_number_scene.instance({})  # Pass an empty dictionary as parameters
		if damage_number_instance:
			damage_number_instance.position = position
			damage_number_instance.get_node("Label").text = str(damage_amount)
			add_child(damage_number_instance) 
	
	
'''
'''
func popup():
	var damage = damage_node.instantiate()
	damage.postion = global_position
	
	get_tree().current_scene.add_child(damage)
	
'''
#func _input(event):
#	if event.is_action_pressed("equip"):
#		spawn_damage_number(5, Vector3(0,1,-.1))


