extends Node

#OLD
signal collect_entity(collectable_entity_resource: BaseCollectableResource)

func emit_collect_entity(collectable_entity_resource: BaseCollectableResource) -> void:
	collect_entity.emit(collectable_entity_resource)
##


signal collected(resource: Resource)


#region item type signals
signal health_collected(collectable_entity_resource: BaseCollectableResource)
signal currency_collected(collectable_entity_resource: BaseCollectableResource)
signal weapon_collected(collectable_entity_resource: BaseCollectableResource)
#endregion

#region UI Update Signals

signal on_update_health(value: int, max_value: int)
signal on_update_currency(value: int)
signal on_pickup_weapon(collectable_name: String)#WHAT DO I PASS?
#endregion



func emit_on_collected(resource: Resource):
	collected.emit(resource)

func emit_health_collected(collectable_entity_resource: BaseCollectableResource) -> void:
	health_collected.emit(collectable_entity_resource)
	print("h collected")
func emit_currency_collected(collectable_entity_resource: BaseCollectableResource) -> void:
	currency_collected.emit(collectable_entity_resource)
	print("c collected")
func emit_weapon_collected(collectable_entity_resource: BaseCollectableResource) -> void:
	weapon_collected.emit(collectable_entity_resource)
	print("w collected")

func emit_on_update_health(value: float, max_value: float) -> void:
	on_update_health.emit(value, max_value)

func emit_on_update_currency(value: int) -> void:
	on_update_currency.emit(value)
	
func emit_on_pickup_weapon(weapon: String): #PASS SOMETHING, PROBABLY NAME
	on_pickup_weapon.emit(weapon)
