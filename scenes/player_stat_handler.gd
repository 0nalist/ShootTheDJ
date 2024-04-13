extends Node3D


@export var max_health: float = 100.0
@onready var player = $".."


'''
VARIABLES TO ALLOW POWERING UP

max_health
	passive health recovery = true
max_stamina
	faster stamina recovery


slides go further
slides go faster


Knockback up
knockback down


chance to gain coins from drops ++, chance to gain health --
vice versa

chunks of flesh give health














'''



var current_health: float = 1.0
var current_coins: int = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	#Connects functions
	SignalBus.health_collected.connect(on_health_collected)
	SignalBus.currency_collected.connect(on_currency_collected)
	SignalBus.weapon_collected.connect(on_weapon_collected)
	
	#Sets variables at start
	current_health = max_health-20
	SignalBus.emit_on_update_health(current_health, max_health)
	SignalBus.emit_on_update_currency(current_coins)

func on_health_collected(resource: BaseCollectableResource) -> void:
	current_health += resource.value
	SignalBus.emit_on_update_health(current_health, max_health)


func on_currency_collected(resource: BaseCollectableResource) -> void:
	current_coins += resource.value
	SignalBus.emit_on_update_currency(current_coins)


func on_weapon_collected(resource: BaseCollectableResource) -> void:
	player.equip(resource.collectable_name)
	SignalBus.emit_on_pickup_weapon(resource.collectable_name)


func take_damage(amount: float):
	current_health -= amount
	SignalBus.emit_on_update_health(current_health, max_health)
	if current_health <= 0:
		player.kill()
	
func add_health(amount: float):
	take_damage(-amount)
	#current_health += amount
	#SignalBus.emit_on_update_health(current_health, max_health)
