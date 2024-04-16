extends Node
class_name Beat_Manager_Class

'''
######## ROOM FOR IMPROVEMENT #############

Not sure if class_name helps-- annoying when it comes up in autofill

NOT AVOIDING LAG lagging beat
	Probably because the triggers are still done in player script
	Should I move more beat logic here?
	Moving math intensive low priority functions (eg enemy navigation) to deprioritized threads could help



'''



signal play_sound(name)
signal beat()
signal sixteenth(current_sixteenth)
#signal finished(sound_player)

var bpm: float = 120.0
#GETSET

var beat_duration := 60.0 / bpm
var sixteenth_duration := beat_duration / 4.0
var last_update_time := 0.0  # Initial time set to 0
var accumulated_time := 0.0
var current_sixteenth := 1  # Start counting from 1
var running := false  # Control variable to start/stop beat calculation


var audio_samples = { 
	"CLAP": preload("res://assets/audio/samples/claponeshot.ogg"),
	"ONEHIHATHIT": preload("res://assets/audio/samples/onehihathit.ogg"),
	"ONEKICK": preload("res://assets/audio/samples/onekick.ogg"),
	"OPENHIHAT": preload("res://assets/audio/samples/openhihat.ogg"),
}

func _ready():
	set_process(true)  # Make sure processing is enabled
	connect("play_sound", play_sound_effect,)
	connect 


func _process(delta):
	if running:
		var current_time = Time.get_ticks_msec() / 1000.0  # Get current time in seconds
		var time_elapsed = current_time - last_update_time
		last_update_time = current_time
		accumulated_time += time_elapsed

		while accumulated_time >= sixteenth_duration:
			accumulated_time -= sixteenth_duration
			emit_signal("sixteenth", current_sixteenth)
			if current_sixteenth >= 16:
				print("bar")
				current_sixteenth = 1  # Reset after reaching 16
			else:
				current_sixteenth += 1
			if current_sixteenth in [1,5,9,13]:
				emit_signal("beat")
				print(beat)

func start_beat_count():
	running = true
	last_update_time = Time.get_ticks_msec() / 1000.0  # Reset the start time to now
	print("Beat count started.")


func set_bpm(new_bpm):
	bpm = new_bpm
	beat_duration = 60.0 / bpm
	sixteenth_duration = beat_duration / 4.0
	print("BPM updated to: ", bpm)



func play_sound_effect(sound_name):
	if audio_samples.has(sound_name):
		var sound_player = AudioStreamPlayer.new()  # Create a new AudioStreamPlayer
		sound_player.stream = audio_samples[sound_name]  # Set its stream
		add_child(sound_player)  # Add it to the scene
		sound_player.play()  # Play the sound
		# Automatically remove it after playback finishes
#		sound_player.connect("finished", _on_sound_finished)##NOT WORKING, SHOULD DEFINITELY FIX TODO

func _on_sound_finished(sound_player):
	sound_player.queue_free()

#Pretty sure this does nothing, no connections
func _on_Player_shoot(weapon_type):
	if weapon_type == "pistol":
		play_sound_effect("ONEHIHATHIT")
		print("PLAYERSHOOTPIST")
	elif weapon_type == "shotgun":
		play_sound_effect("CLAP")
		print("PLAYERSHOOTSHOTGUN")






### QUEUEING BELOW

class BeatAction:
	var target_sixteenth: int
	var action_data: Dictionary

	func _init(_target_sixteenth: int, _action_data: Dictionary):
		target_sixteenth = _target_sixteenth
		action_data = _action_data

var action_queue := []

func enqueue_action(target_sixteenth: int, action_data: Dictionary):
	var item = BeatAction.new(target_sixteenth, action_data)
	action_queue.append(item)

func process_queue():
	var i = 0
	while i < action_queue.size():
		var item = action_queue[i]
		if item.target_sixteenth == current_sixteenth:
			execute_action(item.action_data)
			action_queue.remove_at(i)  # Correct method to remove by index
		else:
			i += 1  # Only increment if we did not remove an item to avoid skipping


func execute_action(action_data: Dictionary):
	# Implement action execution logic here
	print("Executing action:", action_data)


##### ITEMS #######


func handle_sounds(collectable_resource) -> void:
	match collectable_resource.collectable_name:
		"":
			return
		"coin":
			var sound_to_play = house_fourths[randi() % house_fourths.size()]
			#MAKE THIS QUEUE SOUND TO PLAY ON NEXT BAR OR BEAT
			house_fourth_player.stream = sound_to_play
			house_fourth_player.play()
			
		"weapon":
			pass

@onready var house_fourth_player = $ipod/HouseFourthPlayer
var house_fourths = [
	preload("res://assets/audio/pickups/coins/housefourth1.ogg"),
	preload("res://assets/audio/pickups/coins/housefourth2.ogg"),
	preload("res://assets/audio/pickups/coins/househit3.ogg")
	 ]




###### GENERATE BASSLINE to play on enemy hits
'''

func generate_bassline():
	pick random between different note variation patterns
	pick random notes to fill variation pattern
	return bassline


bassline object variables:
	length: how many beats?
	number of unique notes: how many unique audio files are loaded?
	







'''
