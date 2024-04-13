extends Control

@onready var label = $HBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready():
	SignalBus.on_update_currency.connect(update_currency_ui)



func update_currency_ui(value: int) -> void:
	label.text = str(value)
