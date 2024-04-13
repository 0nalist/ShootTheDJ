class_name BaseCollectableResource
extends Resource




@export var collectable_name: String = ""
@export var collectable_texture: Texture = null
@export var scene: PackedScene
@export var scale: float

@export_enum("Health", "Mana", "Currency", "Weapon", "Upgrade") var tag = "EMPTY"

@export var value: int = 0




