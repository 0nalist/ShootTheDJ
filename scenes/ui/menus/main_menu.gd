extends Control

#class_name MainMenu

signal start_game()
signal main_menu_showing()

@onready var buttons_vbox = $MarginContainer/VBoxContainer/ButtonsVbox
@onready var label = $MarginContainer/VBoxContainer/Label


@export var credits_scene: PackedScene


var splash_texts = [
	"- actual title! -",
	"- demo made hastily && with love -",
	"- 2d art is placeholder -",
	"- basic ass features coming soon -",
	"- don't try to use the options menu -",
	"- i'm more of an 'ideas' guy -",
	"- pre-pre-alpha version 0.0.0.04 -",
	'- "LeArN tO cOdE!"... ok -',
	'- all systems are placeholder -',
	'- i just need to implement this new feature... -',
	"- i just need to refactor this system... -",
	"- please help me -",
	"- dear diary, today i made the game worse -",
	"- let me know if you see any bugs -",
	"- 2% optimized -",
	"- let me know if it lags -",
	"- more of a proof of concept than a demo -",
	"- !-- bailando bailando --! -",
	"- copyright? -",
	"- do you fucking love this shit?? -",
	"- more like 5am -",
	"- idk if i will ever understand shaders -",
	"- i know it needs more cowbell -",
	"- like for a 'tbh' -",
	"- 100% bug free! -",
	"- ALPHA 0.0.1 releasing Mayday -",
	"- needs more game juice -"
	
	
]




func _ready():
	focus_button()
	set_random_splash_text()
	

func set_random_splash_text():
	var rand = randi() % splash_texts.size()
	label.text = splash_texts[rand]


func _on_start_game_button_pressed() -> void:
	start_game.emit()
	hide()

func _on_options_button_pressed():
	print("options!")

func _on_quit_game_button_pressed():
	get_tree().quit()



func _on_visibility_changed() -> void:
	if visible:
		focus_button()

func focus_button():
	if buttons_vbox:
		var button: Button = buttons_vbox.get_child(0)
		if button is Button:
			button.grab_focus()
			
			
			
			
			
			
			




@onready var texture_rect = $TextureRect
@onready var margin_container = $MarginContainer




func _on_credits_button_pressed():
	texture_rect.visible = false
	margin_container.visible = false
	var credits = credits_scene.instantiate()
	add_child(credits)
	









'''
============= CREDITS ======================

# HAND MODEL -- Lukky

#GUNS -- PSX pack from itch
	CIGS
	









'''








