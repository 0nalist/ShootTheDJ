#class_name PauseMenu
extends Control


@export var game_manager: Game



# Called when the node enters the scene tree for the first time.
#EXAMPLE OF HOW TO CONNECT A SIGNAL (I THINK)
func _ready():
	hide()
	game_manager.connect("toggle_game_paused", _on_game_manager_toggle_game_paused)



func _on_game_manager_toggle_game_paused(is_paused: bool):
	if(is_paused): # and !get_parent().get_parent().start_game():
		show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		hide()
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _on_resume_button_pressed():
	game_manager.game_paused = false
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	


func _on_quit_button_pressed():
	get_tree().quit()


func _on_restart_button_pressed():
	get_tree().reload_current_scene()
