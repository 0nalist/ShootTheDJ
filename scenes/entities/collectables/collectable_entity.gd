class_name BaseCollectableEntity
extends Area3D
#CoffeeCrow Tutorial

#@onready var sprite_3d = $Sprite3D as Sprite3D
@onready var animation_player = $AnimationPlayer as AnimationPlayer


@export var collectable_resource: BaseCollectableResource = null
#@onready var yellow_splash = $CanvasLayer/YellowSplash
@onready var yellow_splash = $YellowSplash

####### KNOWN BUGS #########
#Not a bug but a to do:
# Make it so YellowSpash is always rendered behing 3d model scene




func _ready():
	#set_texture()
	if collectable_resource.tag == "Weapon":
		yellow_splash.visible = true
	else:
		yellow_splash.visible = false
	var instance = collectable_resource.scene.instantiate()
	add_child(instance)
	area_entered.connect(on_area_entered)
	scale *= collectable_resource.scale
	yellow_splash.scale /= scale
	
	#var material = StandardMaterial3D.new()
	#material.params_depth_draw_mode = StandardMaterial3D.DEPTH_DRAW_ALWAYS
	#yellow_splash.material_override = material
	


func _process(delta):
	rotation.y += 0.05



func on_area_entered(area: Area3D) -> void:
	if area.owner.is_in_group("player"):
		SignalBus.collected.emit(collectable_resource)
		
		handle_sounds()
		queue_free()

# I PROBABLY NEED TO DO AN "IF SOUND AND ANIM FINISHED: QUEUE

'''OLD. but keep
signal collect_entity


func _ready():
	connect("collect_entity", on_collect)
	sprite_3d.texture = collectable_resource.collectable_texture
	handle_animations()

func on_collect() -> void:
	SignalBus.emit_collect_entity(collectable_resource)
	handle_sounds()
	#queue_free()
'''

func handle_animations() -> void:
	match collectable_resource.collectable_name:
		"":
			return
		"coin":
			if collectable_resource.value == 1:
				animation_player.play("coin1")


func handle_sounds() -> void:
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
