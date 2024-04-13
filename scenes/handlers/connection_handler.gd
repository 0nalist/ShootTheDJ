class_name CollectionHandler
extends Area3D

##I THINK I CAN DELETE THIS?

'''
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("area_entered", on_area_entered)
	
	


func on_area_entered(area: Area3D) -> void:
	if area == null:
		return
	
	if area is BaseCollectableEntity:
		#area.emit_signal("collect_entity") #TEMPORARY
		pass
'''
