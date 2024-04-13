extends Control


@onready var health_bar = $HBoxContainer/HealthBar

@onready var label = $Label



func _ready():
	SignalBus.on_update_health.connect(update_health_ui)



func update_health_ui(current_health: int, max_health: int) -> void:
	label.text = str(current_health)+ "/" + str(max_health)
	health_bar.value = current_health

