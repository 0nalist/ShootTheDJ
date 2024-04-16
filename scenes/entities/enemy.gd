class_name Enemy

extends CharacterBody3D


#======= KNOWN BUGS =========

# Can still be damaged while paused
# 

# NAVIGATION causes HEAVY lag when >25 enemies navigating
##Add navigation to 2nd priority thread

signal hurt_player

@onready var bass_on_hit_player = $BassOnHit
var bass_on_hit = [''' ADD BASS SAMPLES OF DIFFERENT TONES HERE
	preload("res://assets/audio/pickups/coins/housefourth1.ogg"),
	preload("res://assets/audio/pickups/coins/housefourth2.ogg"),
	preload("res://assets/audio/pickups/coins/househit3.ogg")'''
	 ]

#@onready var player = get_tree().get_first_node_in_group("player")
@onready var animated_sprite_3d = $AnimatedSprite3D
@onready var death_rattle = $DeathRattle
@onready var sound_on_hit = $SoundOnHit
@onready var vision_ray_cast = $VisionRayCast


@onready var nav_agent = $NavigationAgent3D
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

var dead := false
var health := 30.0
var max_hp := 69.420
var attack_damage := .25

const SPEED := 9.9


var sound_finished = false
var animation_finished = false

func _ready():
	await get_tree().create_timer(1.0).timeout #Need this or else fail to get player
	player = get_tree().get_first_node_in_group("player")
	print(player)
	#player = get_node("res://scenes/entities/player/player.tscn")
	#await get_tree().create_timer(1.0).timeout #do we need this?
	#player = get_tree().get_nodes_in_group("player")[0]


enum States{
	IDLE,
	SEARCH,
	CHASE,
	ATTACK,
	JUMP,
	DYING,
	#POUNCE,
	#
}
var current_state = States.IDLE
var previous_state = States.IDLE

var player_in_detection_area: bool = false

var detection_distance: float = 1000.0

#var distance_to_player = global_position.distance_to(player.global_position)

func _physics_process(delta):
	match current_state:
		States.IDLE:
			handle_idle_state(delta)
		States.SEARCH:
			handle_search_state(delta)
		States.CHASE:
			handle_chase_state(delta)
		States.ATTACK:
			handle_attack_state(delta)
		States.JUMP:
			handle_jump_state(delta)
		States.DYING:
			handle_dying_state(delta)
	if previous_state != current_state:
		$StateLabel.text = str(current_state)


func handle_idle_state(_delta):
	$AnimatedSprite3D.play("idle")
	if player_detected():
		current_state = States.CHASE

func handle_chase_state(_delta):
	nav_agent.target_position = player.position
	
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	$AnimatedSprite3D.play("walk_fwd")
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED 
	move_and_slide()
	
	
	if player_in_attack_range():
		current_state = States.ATTACK
	
	if distance_to_player() > 100:
		current_state = States.IDLE

func handle_attack_state(_delta):
	
	if player_in_attack_range():
		$AnimatedSprite3D.play("attack")
		player.damage_player(attack_damage)
	if distance_to_player() > 3.9:
		current_state = States.CHASE
		
	

func handle_search_state(_delta):
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	move_and_slide()
	if player_detected():
		current_state = States.CHASE


func handle_jump_state(_delta):
	print("ejump")

func player_detected() -> bool:
	if not player_in_detection_area or player == null or dead:
		return false
	
	if player_in_detection_area:
		return true
	
	'''
	#var direction_to_player = (player.global_transform.origin - global_transform.origin).normalized()
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	#$VisionRayCast.cast_to = direction_to_player * direction_distance
	$VisionRayCast.force_raycast_update()
	
	if $VisionRayCast.is_colliding():
		var collider = $VisionRayCast.get_collider()
		if collider == player:
			return true
			'''
	return false


func distance_to_player() -> float:
	return global_position.distance_to(player.global_position)


func player_in_attack_range() -> bool:
	if distance_to_player() < 3.3:
		return true
	else:
		return false



func _on_vision_area_body_entered(body):
	if body != null and body.is_in_group("player") and not dead:
		player_in_detection_area = true


func _on_vision_area_body_exited(body):
	if body != null and body.is_in_group("player") and not dead:
		player_in_detection_area = false
		current_state = States.IDLE## FOR DEBUGGING LAG



func take_damage(value):
	health -= value
	sound_on_hit.play()
	animated_sprite_3d.play("take_damage")#Not playing long enough
	#%HealthBar.value = health
	if health <= 0 and current_state != States.DYING:
		current_state = States.DYING
	else:
		current_state = States.CHASE
	
	#ANIMATE DAMAGE NUMBERS. Preferably on site of impact--so maybe in gun manager?

func handle_dying_state(_delta):
	if not dead:  # Ensure this runs once
		$CollisionShape3D.disabled = true
		death_rattle.play()
		animated_sprite_3d.play("die")
		dead = true  # Prevents re-entry into this block



func _on_animated_sprite_3d_animation_finished():
	pass # Replace with function body.
	animation_finished = true
	if sound_finished:
		finalize_death()

func _on_death_rattle_finished():
	sound_finished = true
	if animation_finished:
		finalize_death()
	finalize_death()

func finalize_death():
	dead = true
	queue_free()










