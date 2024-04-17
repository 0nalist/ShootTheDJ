extends CanvasLayer

class_name UI



signal start_game()

@onready var main_menu = %MainMenu

var player: Player


'''
@onready var SFX_BUS_ID
@onready var MUSIC_BUS_ID
'''


func _on_main_menu_start_game() -> void:
	start_game.emit()
	player = get_tree().get_first_node_in_group("player")
	#player.pistol_entered_cooldown.connect(_on_pistol_cooldown_started)
	player.pistol_cooldown_started.connect(_on_pistol_cooldown_started)
	player.pistol_cooldown_updated.connect(_on_pistol_cooldown_updated)
	
	pistol_cooldown_label.text = str(player.pistol_firing_duration)


func _ready():
	#BeatManager.beat.connect(_on_beat)
	#BeatManager.sixteenth.connect(_on_sixteenth)
	pass



##This should probably all be housed in a pistolui script##
#Remember to change this if i change label node
@onready var pistol_cooldown_label = $Control/MarginContainer/HBoxContainer2/PistolCooldownUI/VBoxContainer/PistolCooldown

func _on_pistol_cooldown_started(beats_left: int):
	pistol_cooldown_label.modulate = Color(1, 0, 0)
	pistol_cooldown_label.text = str(beats_left)

func _on_pistol_cooldown_updated(beats_left: int):
	if beats_left <= 0:
		pistol_cooldown_label.modulate = Color(0, 1, 0)
		var posbeats = player.pistol_firing_duration + beats_left
		pistol_cooldown_label.text = str(posbeats)
	else: pistol_cooldown_label.text = str(beats_left)
