extends Camera3D


@onready var fps_rig = $FPSRig
@onready var shotgun_animation_player = $FPSRig/Shotun/ShotgunAnimationPlayer
@onready var pistol_animation_player = $FPSRig/Pistol/PistolAnimationPlayer

@onready var one_hihat_1 = $ipod/OneHihat1
@onready var open_hi_hat_hit = $ipod/OpenHiHatHit
@onready var one_kick_punch = $ipod/OneKickPunch
@onready var one_clap = $ipod/OneClap






# Called when the node enters the scene tree for the first time.
func _ready():
	$FPSRig/Shotun.visible = false
	$FPSRig/Pistol.visible = false
	
	
	
	
	

func _process(delta):
	fps_rig.position.x = lerp(fps_rig.position.x, 0.0, delta*5)
	fps_rig.position.y = lerp(fps_rig.position.y, 0.0, delta*5)
	


func sway(sway_amount):
	fps_rig.position.x -= sway_amount.x * 0.00017
	fps_rig.position.y += sway_amount.y * 0.00017
	


#TEMP FOR 2D fist
@onready var right_fist_sprite_3d = $FPSRig/GunManager/RightFistSprite3D
func punch_fist():
	right_fist_sprite_3d.play("punch")


func fire_shotgun():
	shotgun_animation_player.queue("fire")

func fire_pistol():
	pistol_animation_player.queue("fire")
	#one_hihat_1.play()

func equip_shotgun():
	$FPSRig/Shotun.visible = true
	shotgun_animation_player.queue("equip")
	

func equip_pistol():
	$FPSRig/Pistol.visible = true
	pistol_animation_player.queue("equip")


