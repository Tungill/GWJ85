extends CharacterBody2D
class_name PlayerCharacter

@export var health_component: HealthComponent

var is_alive: bool = true:
	# INFO Use the setter to trigger a signal if bool's value is false.
	set(value):
		if value == false:
			EventBus.player.player_died.emit()


func _ready() -> void:
	# INFO Change is_alive to false when the health from HealthComponent reaches 0.
	# Using a lambda function.
	health_component.health_depleted.connect(func change_is_alive() -> void: is_alive = false)
	
	#region DEBUG
	if health_component == null:
		push_error("PlayerCharacter health component is not assigned.")
	
	health_component.health_changed.connect(
		func(old_health: int, new_health:int) -> void: 
			print("Old: ", old_health, " & New:", new_health)
			)
	#endregion


func _input(event: InputEvent) -> void:
	
	#region DEBUG
	if event.is_action_pressed("debug_action_1") and OS.is_debug_build():
		take_damage(5)
	if event.is_action_pressed("debug_action_2") and OS.is_debug_build():
		health_component.heal_for(12)
	#endregion


func take_damage(value: int) -> void:
	# NOTE The ennemies entities will trigger this function when they detect the
	# PlayerHitbox and match it as part of the PlayerCharacter.
	health_component.take_damage(value)
	
	# TBD Trigger visual impact on damage.
	# Or connect to the health_changed signal instead.
