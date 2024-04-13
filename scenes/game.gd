extends Node
class_name Game

@export var PlayerScene: PackedScene
@export var WorldScene: PackedScene
@export var ui: UI


var player: Player
var world: World

signal toggle_game_paused(is_paused: bool)
#signal pause_beat_system
#signal resume_beat_system

func _ready():
	ui.main_menu.visible = true


var game_paused: bool = false:
	get:
		return game_paused
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)


func _input(event: InputEvent):
	if(event.is_action_pressed("esc")):
		game_paused = !game_paused
		if game_paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#		emit_signal("pause_beat_system")
		#elif !start_game():
		#	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#		emit_signal("resume_beat_system")



func start_game():
	print("gamin")
	game_paused = false
	world = WorldScene.instantiate()
	add_child(world)
	move_child(world, 0)
	player = PlayerScene.instantiate()
	world.add_child(player)
	#SPAWN LOCATION
	#player.position = Vector3(31.88154, 8.287825, 4.634374) # first test room
	player.position = Vector3(-23.43802, 69.40746, 15.88568)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#player.collected.connect(ui._on_collected)
	
	
	BeatManager.start_beat_count()
	




func _on_ui_start_game():
	start_game()
