extends CharacterBody3D

class_name Player

# ========== KNOWN BUGS ================
#
# rhythm is STILL tied to processing speed :( But we did begin moving audio to BeatManager, which could help optimize
#
# h velocity not conserved when jumping out of slide
#
# Resizing the screen in game does not resize subviewport
#
# =================== TO DO =====================
#
# Inventory
# Beat programmer
# Projectile system
# experiment with 3d low poly enemy
# parkour style climb up. 
##	FAILED TO IMPLEMENT. Non functioning code should exist commented out
# Double Jump-- Scratch that-- SHOTGUN JUMP !!!
# stairs... ramps? Would be nice to have some step up logic to avoid getting caught on snags -- good game juice
# smaller collision box on slide
# optimize enemies--lag when too many too close
'''
Ideas!

Game mechanics
"TAXES" After 32,64,128,256 bars you lose a portion of your coin but gain an awesome temporary powerup
	Clap -- Squash foes and deal a shockwave. Extends shotgun, with knockback set to 0 except for shotgun jump
	Lasts 16 bars
		Maybe Player gets decision whether to keep it for another 16 bars, but they have to put their other weapons down for the bonus bars



Specialized shopkeepers



'''

signal collected(collectable)

func collect(collectable):
	collected.emit(collectable)

# ======== PLAYER BODY PARTS ======== #
@onready var head = $Head
@onready var main_camera = %MainCamera
@onready var stamina_bar = %StaminaBar
@onready var gun_camera = $Head/MainCamera/SubViewportContainer/SubViewport/view_model_camera

# PLAYER VARIABLES
@export var stamina: float = 70.0
@export var max_stamina: float = 100.0
var dead = false

# ======= GUNS/WEAPONS ======= #
@onready var gun_ray = $Head/MainCamera/GunRay
@onready var melee_ray = $Head/MainCamera/MeleeRay

# ==== = SOUNDS = ==== #
@onready var one_hi_hat_hit = $ipod/OneHihat1
@onready var open_hi_hat_hit = $ipod/OpenHiHatHit
@onready var one_kick_punch = $ipod/OneKickPunch
@onready var clap = $ipod/OneClap

# FINE TUNE JUMP MECHANICS
@export_category("Movement Parameters")
@export var Jump_Peak_Time: float = .4
@export var Jump_Fall_Time: float = .5
@export var Jump_Height: float = 4.269

# STAMINA SYSTEM #
var stamina_recovery = 0.5
var jump_stamina_cost = 15.0
var slide_stamina_cost = 17.0

# CAMERA SETTINGS
var mouse_sens = 0.05
var camera_rotation = Vector2(0,0)
const BOB_FREQ = 2
const BOB_AMP = .09
var t_bob = 0.0

# Movement calculated from acceleration and friction instead of speed
var accel = 90.0
const FRICTION = .85
var Jump_Velocity: float = 17.3

# WALLJUMP KIT
const WALL_FRICTION = .86
const WALL_JUMP_DAMPER = .77
const WALL_JUMP_VELOCITY = 20.0
const WALL_JUMP_ALTERING = 25

# WALLJUMP STATE SENSOR
const FLOOR = 0
const WALL = 1
const AIR = 2
const SLIDE = 4
var current_state := AIR

var Jump_Gravity: float = 17.0
var Fall_Gravity: float = 17.0

# GUN INITIALIZATION
var one_shooting = false
var two_shooting = true
var three_shooting = true

var holding_pistol = false
var holding_shotgun = false
var holding_right_fist = true

var one_stack := []
var two_stack := []
var three_stack := []

func calculate_movement_parameters()->void:
	Jump_Gravity = (2*Jump_Height)/pow(Jump_Peak_Time,2)
	Fall_Gravity = (2*Jump_Height)/pow(Jump_Fall_Time,2)
	Jump_Velocity = Jump_Gravity * Jump_Peak_Time



func _ready():
	$Head/MainCamera/SubViewportContainer/SubViewport.size = DisplayServer.window_get_size() # ALSO DO THIS ON RESIZING
	
	# Connect to BeatManager
	BeatManager.sixteenth.connect(_on_sixteenth)
	BeatManager.beat.connect(_on_beat)
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	calculate_movement_parameters()
	
	%StaminaBar.value = stamina # this next
	
	drum_machine_factory_reset()
	
	pistol_cooldown_timer.wait_time = cooldown_timer




# ========= B E A T S H O T   L O G I C ========== #

var current_sixteenth: int = 0
var single_shot_queued := false
var continuous_firing := false
var pistol_cooldown = false
var cooldown_timer = BeatManager.sixteenth_duration * 1.47  # Cooldown after first shot
var next_shot_sixteenth := 0
var pistol_shot_queue = []  # Array to hold queued shots
var max_queued_pistol_shots = 1  # Maximum number of shots that can be queued

var last_click_time := 0.0
const DOUBLE_CLICK_THRESHOLD = 0.25  # 250 milliseconds between clicks
var is_continuous_firing_enabled := false

var hat_pats = {"pistol": [1,2,3,4,5, 7, 11, 15]}  # Example pattern for the pistol

@onready var pistol_cooldown_timer = $Head/MainCamera/GunRay/PistolCooldownTimer

func debug_kick():
	one_kick_punch.play()

func _on_sixteenth(sixteenth):
	current_sixteenth = sixteenth
	print("Current Sixteenth: ", sixteenth)  # Debug output
	process_queued_shots()
	if continuous_firing:
		queue_shot_on_pattern()
	if sixteenth in [1,5,9,13]:
		debug_kick()

func process_queued_shots():
	var i = 0
	while i < pistol_shot_queue.size():
		if pistol_shot_queue[i] == current_sixteenth:
			fire_pistol()
			pistol_shot_queue.remove_at(i)  # Remove shot from queue after firing
		else:
			i += 1

func fire_pistol():
	BeatManager.emit_signal("play_sound", "ONEHIHATHIT")
	print("Pistol fired at sixteenth: ", current_sixteenth)
	gun_camera.fire_pistol()  # Assuming this method manages the animation
	if gun_ray.is_colliding() and gun_ray.get_collider().has_method("take_damage"):
		gun_ray.get_collider().take_damage(pistol_damage)
		print("hihathit")
		heal(.1)
	velocity *= 0.95
	pistol_cooldown = true
	pistol_cooldown_timer.start()

func _on_pistol_cooldown_timer_timeout():
	pistol_cooldown = false
	if continuous_firing:  # If still holding down, queue next patterned shot
		queue_shot_on_pattern()

func queue_shot_on_pattern():
	if pistol_shot_queue.size() < max_queued_pistol_shots and not pistol_shot_queue.has(current_sixteenth):
		var next_sixteenth = find_next_valid_sixteenth()
		if next_sixteenth != -1 and !pistol_shot_queue.has(next_sixteenth):
			pistol_shot_queue.append(next_sixteenth)
			print("Shot queued for sixteenth: ", next_sixteenth)

func find_next_valid_sixteenth():
	var current_index = hat_pats["pistol"].find(current_sixteenth)
	if current_index == -1 or current_index + 1 >= hat_pats["pistol"].size():
		return hat_pats["pistol"][0]  # Wrap around if needed
	else:
		return hat_pats["pistol"][current_index + 1]




var beat: int = 0

func _on_beat():
	beat += 1
	print(beat)

func _physics_process(delta):
	gun_camera.global_transform = main_camera.global_transform
	update_stamina()
	if not is_on_floor():
		if velocity.y > 0:
			velocity.y -= Jump_Gravity * delta
		else:
			velocity.y -= Fall_Gravity * delta
	if dead:
		return
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_fwd", "move_bwd")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x += direction.x * accel * delta
		velocity.z += direction.z * accel * delta
	handle_jump(direction)
	move_and_slide()
	update_state()
	velocity.x *= FRICTION
	velocity.z *= FRICTION
	# WALL FRICTION FROM WALLJUMP KIT
	if current_state == WALL:
		velocity.y *= WALL_FRICTION
	# HEADBOB
	if not sliding:
		t_bob += delta * velocity.length() * float(is_on_floor())
		main_camera.transform.origin = _headbob(t_bob)

func _input(event):
	if dead:
		return
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
		gun_camera.sway(Vector2(event.relative.x, event.relative.y))
		
	if holding_pistol and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			# Check if this click is within the threshold to be considered a double-click
			var current_time = Time.get_ticks_msec() / 1000.0
			if current_time - last_click_time <= DOUBLE_CLICK_THRESHOLD:
				# Toggle continuous firing
				is_continuous_firing_enabled = !is_continuous_firing_enabled
				continuous_firing = is_continuous_firing_enabled
				print("Continuous firing toggled:", is_continuous_firing_enabled)
			else:
				# Not a double click, handle normal firing
				if not pistol_cooldown:
					print("Fire pistol pressed")
					fire_pistol()  # Fire immediately on press
					if not is_continuous_firing_enabled:
						continuous_firing = true
			# Update last click time
			last_click_time = current_time
		else:
			# Handle mouse release for non-toggled mode
			if not is_continuous_firing_enabled:
				print("Fire pistol released")
				continuous_firing = false
		
		
		
		
		'''
	if event.is_action_pressed("fire_pistol"):
		if holding_pistol and not event.is_echo() and not pistol_cooldown:
			print("Fire pistol pressed")
			fire_pistol()  # Fire immediately on press
			continuous_firing = true
	elif event.is_action_released("fire_pistol"):
		print("Fire pistol released")
		continuous_firing = false'''
		
		
	if Input.is_action_just_pressed("slide"):
		slide()
	if Input.is_action_just_pressed("equip"):
		pass
	if Input.is_action_just_pressed("esc"):
		pass

func camera_look(movement: Vector2):
	camera_rotation += movement
	camera_rotation.y = clamp(camera_rotation.y, -1.5, 1.6)
	transform.basis = Basis()
	main_camera.transform.basis = Basis()
	rotate_object_local(Vector3(0,1,0), -camera_rotation.x)
	main_camera.rotate_object_local(Vector3(1,0,0), -camera_rotation.y)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func update_state():
	if is_on_wall_only():
		current_state = WALL
	elif sliding:
		current_state = SLIDE
	elif is_on_floor():
		current_state = FLOOR
	else:
		current_state = AIR

func update_stamina():
	%StaminaBar.value = stamina
	if stamina < max_stamina:
		if current_state != SLIDE and current_state != AIR:
			stamina += stamina_recovery
	if stamina <= 0:
		stamina = 0
	%StaminaBar.value = stamina

func handle_jump(dir):
	if Input.is_action_just_pressed("jump") and can_jump:
		#if can_climb():
		#	climb()
		if stamina <= jump_stamina_cost: return
		if current_state == AIR: return
		stamina -= jump_stamina_cost
		if current_state == FLOOR:
			velocity.y = Jump_Velocity
		if current_state == SLIDE:
			velocity.y += Jump_Velocity
			velocity = Vector3(velocity.x * slide_speed, Jump_Velocity, velocity.z * slide_speed)
		if current_state == WALL:
			velocity = get_wall_normal() * WALL_JUMP_VELOCITY
			print(get_wall_normal())
			velocity += -dir * WALL_JUMP_ALTERING
			velocity.y += Jump_Velocity * WALL_JUMP_DAMPER



var can_jump := true
var camera_can_move := true
var is_crouching := false

func can_climb():
	if !$Head/ChestRay3D.is_colliding():
		return false
	for ray in $Head/ReachRays.get_children():
		if ray.is_colliding():
			return false
	return true

func climb():
	pass

func damage_player(value: float):
	$PlayerStatHandler.take_damage(value)

func heal(value: float):
	$PlayerStatHandler.add_health(value)

var sliding = false
var slide_time = 0.314159
var slide_speed = 3.14
var slide_cooldown = 0.1

func slide():
	if sliding: return
	if stamina <= slide_stamina_cost: return
	else:
		if is_on_floor():
			sliding = true
			stamina -= slide_stamina_cost
			var preslide_speed = accel
			accel *= slide_speed
			get_tree().create_tween().tween_property(main_camera, "position:y", main_camera.position.y-.8, slide_time/2 )
			await get_tree().create_timer(slide_time).timeout
			accel = preslide_speed
			get_tree().create_tween().tween_property(main_camera, "position:y", main_camera.position.y+.8 , slide_time/2 )
			await get_tree().create_timer(slide_cooldown).timeout
			sliding = false

func equip(weapon: String):
	if weapon == "shotgun1":
		equip_shotgun()
	if weapon == "pistol1":
		equip_pistol()

var pistol_damage := 3
var shotgun_damage := 7
var right_fist_damage := 5

func equip_pistol():
	gun_camera.equip_pistol()
	holding_pistol = true

func equip_shotgun():
	holding_shotgun = true
	gun_camera.equip_shotgun()

func equip_right_fist():
	holding_right_fist = true

func start_stop_weapons_2slot():
	if not two_shooting:
		two_shooting = true
	else:
		two_shooting = false

func start_stop_weapons_3slot():
	if not three_shooting:
		three_shooting = true
	else:
		three_shooting = false

var one_slot_current = 0
func cycle_one():
	one_slot_current = (one_slot_current + 1) % hat_pats.size()
	if one_slot_current > hat_pats.size():
		one_slot_current = 0

var two_slot_current = 0
func cycle_two():
	two_slot_current = (two_slot_current + 1) % snare_pats.size()
	if two_slot_current > snare_pats.size():
		two_slot_current = 0

var three_slot_current = 0
func cycle_three():
	three_slot_current = (three_slot_current + 1) % kick_pats.size()
	if three_slot_current > kick_pats.size():
		three_slot_current = 0

var hat_patterns: Array = [[],[],[]]
var user_hats: Array = []
var snare_pats: Array = [[]]
var kick_pats: Array = [[],[]]

func set_user_hats():
	user_hats.append(1)
	print(user_hats)

func drum_machine_factory_reset():
	hat_pats[0] = [3,7,11,15]
	hat_pats[1] = [1,2,3,5,6,7,9,10,11,12,13,14]
	hat_pats[2] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16]
	snare_pats[0] = [5,13]
	kick_pats[0] = [1,11]
	kick_pats[1] = [1,5,9,13]

func shoot_play_closed_hihat():
	#one_hi_hat_hit.play()
	#gun_camera.fire_pistol()
	if gun_ray.is_colliding() and gun_ray.get_collider().has_method("take_damage"):
		gun_ray.get_collider().take_damage(pistol_damage)
		print("hihathit")
		heal(.1)
	velocity *= 0.95

func shoot_play_shotgun():
	#clap.play()
	gun_camera.fire_shotgun()
	var backward_direction = -global_transform.basis.z
	var push_force = backward_direction * 25
	velocity -= push_force
	if gun_ray.is_colliding() and gun_ray.get_collider().has_method("take_damage"):
		gun_ray.get_collider().take_damage(right_fist_damage)
		heal(.1)
	print(gun_ray.get_collider())

func shoot_play_kick_punch():
	#one_kick_punch.play()
	var backward_direction = -global_transform.basis.z
	var push_force = backward_direction * 15
	velocity += push_force
	if melee_ray.is_colliding() and melee_ray.get_collider().has_method("take_damage"):
		melee_ray.get_collider().take_damage(right_fist_damage)
		heal(.1)
		nudge_bass_cutoff_filter(-10)
		print("punch")
	velocity *= 0.8

func nudge_bass_cutoff_filter(value):
	pass

func exit_game():
	get_tree().quit()

func restart():
	get_tree().reload_current_scene()

func kill():
	dead = true
	$CanvasLayer/DeathScreen.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_restart_button_button_up():
	restart()

func _on_quit_button_pressed():
	restart()