class_name Enemy

extends CharacterBody3D


#======= KNOWN BUGS =========
# NOT currently playing deathrattle

# Can still be damaged while paused
# 

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
	#player = get_node("res://scenes/entities/player/player.tscn")
	
	await get_tree().create_timer(1.0).timeout #do we need this?
	
	#player = get_tree().get_first_node_in_group("player")
	player = get_tree().get_nodes_in_group("player")[0]
	
	#death_rattle.connect("finished", Callable(self, "_on_death_rattle_finished"))
	#animated_sprite_3d.connect("animation_finished", Callable(self, "_on_animated_sprite_3d_animation_finished"))


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
	if not player_in_detection_area or player == null:
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
	if body != null and body.is_in_group("player"):
		player_in_detection_area = true


func _on_vision_area_body_exited(body):
	if body != null and body.is_in_group("player"):
		player_in_detection_area = false
		current_state = States.IDLE## FOR DEBUGGING LAG


'''
func _on_detection_area_3d_body_entered(body):


func _on_detection_area_3d_body_exited(body):
'''



func take_damage(value):
	health -= value
	sound_on_hit.play()
	animated_sprite_3d.play("take_damage")#Not playing long enough
	#%HealthBar.value = health
	if health <= 0 and current_state != States.DYING:
		current_state = States.DYING
	
	#ANIMATE DAMAGE NUMBERS. Preferably on site of impact--so maybe in gun manager?

func handle_dying_state(_delta):
	if not dead:  # Ensure this runs once
		$CollisionShape3D.disabled = true
		death_rattle.play()
		animated_sprite_3d.play("die")
		dead = true  # Prevents re-entry into this block



func _on_animated_sprite_3d_animation_finished():
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







# OLD STATE MACHINE INITIALIZATION 
'''
var previous_state := ""
var current_state := "idle"
var next_state := "idle"


func _physics_process(delta):
	if dead:
		return
	if player == null:
		return
	if previous_state != current_state:
		$StateLabel.text = current_state
	previous_state = current_state
	current_state = next_state
	
	match current_state:
		"idle":
			#if previous_state != current_state:
			#	pass
			idle()
			
		"chase":
			#await get_tree().create_timer(0.1).timeout
			#nav_agent.target_position = player.position
			chase(delta)
		
		"pounce":
			pass
		"attack":
			attack()
			
		"stagger":
			pass #
		"dead":
			die()


func idle():
	if previous_state != current_state:
		$AnimatedSprite3D.play("idle")




func chase(_delta):
	look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	#if vision_ray.is_colliding() and vision_ray.get_collider() != null:
	$AnimatedSprite3D.play("walk_fwd")
	velocity = Vector3.ZERO
	nav_agent.set_target_position(player.global_transform.origin)
	var next_nav_point = nav_agent.get_next_path_position()
	velocity = (next_nav_point - global_transform.origin).normalized() * SPEED 
	move_and_slide()
	#else: return
	

	
	# Not working as intended. Supposed to follow if more than 1 unit away
	#velocity = (nav_agent.get_next_path_position() - position).normalized() * SPEED * delta
	#if player.position.distance_to(position) > 1:
		#move_and_collide(velocity)
	#	$AnimatedSprite3D.play("walk_fwd")
		#move_and_slide()
	


func attack():
	#if previous_state != current_state:
	$AnimatedSprite3D.play("attack")
	if player_in_range:
		player.damage_player(attack_damage)
		await get_tree().create_timer(1.5).timeout #doesnt seem to stop attack damage
	#if $VisionRayCast.is_colliding() and $VisionRayCast.get_collider().has_method("damage_player"):
	#	$VisionRayCast.get_collider().damage_player(attack_damage)
#	await get_tree().create_timer(.5).timeout
#	if player_in_range:
#		next_state = "attack"

func _on_attack_timer_timeout():
	if current_state == "attack":
		print("do a damage")




func _on_vision_timer_timeout():
	check_sight()

func check_sight():
	var overlaps = $VisionArea.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.is_in_group("player"):
				var player_position = overlap.global_transform.origin
				$VisionRayCast.look_at(player_position, Vector3.UP)
				$VisionRayCast.force_raycast_update()
				if $VisionRayCast.is_colliding():
					var collider = $VisionRayCast.get_collider()
					if collider.is_in_group("player"):
						next_state = "chase"
					else: print("where??")





func take_damage(value):
	health -= value
	animated_sprite_3d.play("take_damage") #Not playing long enough, getting interrupted
	#%HealthBar.value = health
	if health <= 0:
		die()
	
	#ANIMATE DAMAGE NUMBERS. Preferably on site of impact--so maybe in gun manager?

func die():
	dead = true
	death_rattle.play()
	animated_sprite_3d.play("die")
	$CollisionShape3D.disabled = true
	await get_tree().create_timer(1.5).timeout
	queue_free()



#If player enters attack range
func _on_area_3d_body_entered(body):
	if body.is_in_group("player"):
		next_state = "attack"
		player_in_range = true
		

#If player leaves attack range
func _on_area_3d_body_exited(body):
	if body.is_in_group("player"):
		next_state = "chase"
		player_in_range = false


#If player enters detection range
func _on_detection_area_3d_body_entered(body):
	#if LINE OF SIGHT
	if body.is_in_group("player"):
		next_state = "chase"
	

func _on_detection_area_3d_body_exited(body):
	if body != null and body.is_in_group("player"):
		await get_tree().create_timer(4.7).timeout
		next_state = "idle"
	else: pass



'''






