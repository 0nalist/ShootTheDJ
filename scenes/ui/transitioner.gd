class_name Transitioner
extends Control

# Fade Out, Fade In & Scene Switching Tutorial -- Chris' Tutorials


@onready var texture_rect: TextureRect = $TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	texture_rect.visible = false

