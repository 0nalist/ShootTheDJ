extends CanvasLayer

class_name UI



signal start_game()

@onready var main_menu = %MainMenu


'''
@onready var SFX_BUS_ID
@onready var MUSIC_BUS_ID

'''



func _on_main_menu_start_game() -> void:
	start_game.emit()




func _ready():
	pass


