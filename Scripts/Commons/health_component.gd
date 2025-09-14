extends Node2D
class_name HealthComponent

signal health_changed(old_health: int, new_health: int)
signal health_depleted

@export_range(1, 100, 1,  "or_greater")
var _max_health: int = 10

var health: int: set = _set_health


func _ready() -> void:
	health = _max_health


func take_damage(damage_value: int) -> void:
	if health > 0:
		health = -damage_value


func heal_for(heal_value: int) -> void:
	if health > 0:
		health = +heal_value


func _set_health(value: int) -> int:
	var old_health: int = health
	health += value
	if health <= 0:
		health_depleted.emit()
		health = 0
	health_changed.emit(old_health, health)
	return health
