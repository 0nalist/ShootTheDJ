class_name  CollectableManager

extends Node

#var current_coin_count: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.collected.connect(on_collectable_collected)
	


func on_collectable_collected(resource: BaseCollectableResource) -> void:
	match resource.tag:
		"Health":
			SignalBus.emit_health_collected(resource)
		"Currency":
			SignalBus.emit_currency_collected(resource)
		"Weapon":
			SignalBus.emit_weapon_collected(resource)
		"":
			print("ERROR: NO TAG SPECIFIED !!!!")



