extends Control

@export var bg_color : Color = Color.BLACK
@export var to_scene : PackedScene = null
@export var title_color := Color.BLUE_VIOLET
@export var text_color := Color.WHITE
@export var title_font : FontFile = null
@export var text_font : FontFile = null
@export var Music : AudioStream = null
@export var Use_Video_Audio : bool = false
@export var Video : VideoStream = null

const section_time := 2.2
const line_time := 0.33
const base_speed := 73
const speed_up_multiplier := 10.1

var scroll_speed : float = base_speed
var speed_up := false

@onready var colorrect := $ColorRect
@onready var videoplayer := $VideoPlayer
@onready var line := $CreditsContainer/Line
@onready var htdj_loop = $ipod/HTDJ_loop



var started := false
var finished := false

var section
var section_next := true
var section_timer := 0.0
var line_timer := 0.0
var curr_line := 0
var lines := []

var credits = [
	[
		"SHOOT THE DJ",
		
	],[
		"Director",
		"Sam"
	],[
		"Executive Producer",
		"Sam"
	],[
		"Game Design",
		"Sam"
	],[
		"Programming",
		"Sam"
	],[
		"Art Direction",
		"Sam"
	],[
		"Art & Assets",
		"Wildenza -- PSX Asset Pack",
		'"Nun PSX style Lowpoly" (https://skfb.ly/oMBzG) by Gabrielonstartdesk',
		"Lukky -- Arms Mesh",
		"Sam",
	],[
		"Textures & Shaders",
		"Little Martian - Retro Pixel Textures Pack",
		"Sam",
	],[
		"Music",
		"Sam",
		"Morrissey"
	],[
		"Sound Effects",
		"Sam"
	],[
		"Testers",
		"! ! ! ! ! !  Your name here  ! ! ! ! ! !",
		#"Name 2",
		#"Name 3"
	],[
		"Tools used",
		"Developed with Godot Engine",
		#"https://godotengine.org/license",
		"",
		"Audio made with Ableton",
		"",
		"3D Modeling: Blender and TrenchBroom",
		"",
		"Textures: Aseprite"
		#"Art created with My Favourite Art Program",
		#"https://myfavouriteartprogram.com"
	],[
		"Youtube Tutorialists",
		'Godotneers',
		"CoffeeCrow",
		"StayAtHomeDev",
	],[
		"Special thanks",
		'Morrissey',
		#"My parents",
		#"My friends",
	],[
		"DISCLAIMERS",
		'no DJs were harmed in the production of this game',
		"No AI generated art or images were used",
		"ChatGPT was used for debugging",
	],[
		"Copyright",
		'Sam'
	]
]

func _ready():
	htdj_loop.play()
	htdj_loop.volume_db = 0
	
	colorrect.color = bg_color
	videoplayer.set_stream(Video)
	if !Use_Video_Audio:
		var stream = AudioStreamPlayer.new()
		stream.set_stream(Music)
		add_child(stream)
		videoplayer.set_volume_db(-80)
		stream.play()
	else:
		videoplayer.set_volume_db(0)
	videoplayer.play()
	

func _process(delta):
	scroll_speed = base_speed * delta
	
	if section_next:
		section_timer += delta * speed_up_multiplier if speed_up else delta
		if section_timer >= section_time:
			section_timer -= section_time
			
			if credits.size() > 0:
				started = true
				section = credits.pop_front()
				curr_line = 0
				add_line()
	
	else:
		line_timer += delta * speed_up_multiplier if speed_up else delta
		if line_timer >= line_time:
			line_timer -= line_time
			add_line()
	
	if speed_up:
		scroll_speed *= speed_up_multiplier
	
	if lines.size() > 0:
		for l in lines:
			l.set_global_position(l.get_global_position() - Vector2(0, scroll_speed))
			if l.get_global_position().y < l.get_line_height():
				lines.erase(l)
				l.queue_free()
	elif started:
		finish()




func finish():
	if not finished:
		finished = true
		if to_scene != null:
			var path = to_scene.get_path()
			get_tree().change_scene_to_file(path)
		else:
			#TODO: Add audio fade out here before reloading scene
			
			get_tree().reload_current_scene()





func add_line():
	var new_line = line.duplicate()
	new_line.text = section.pop_front()
	lines.append(new_line)
	if curr_line == 0:
		if title_font != null:
			new_line.set("theme_override_fonts/font", title_font)
		new_line.set("theme_override_colors/font_color", title_color)
	
	else:
		if text_font != null:
			new_line.set("theme_override_fonts/font", text_font)
		new_line.set("theme_override_colors/font_color", text_color)
	
	$CreditsContainer.add_child(new_line)
	
	if section.size() > 0:
		curr_line += 1
		section_next = false
	else:
		section_next = true


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		finish()
	if event.is_action_pressed("ui_down") and !event.is_echo():
		speed_up = true
	if event.is_action_released("ui_down") and !event.is_echo():
		speed_up = false
