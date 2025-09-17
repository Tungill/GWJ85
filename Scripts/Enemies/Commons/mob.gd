extends RigidBody2D
class_name  Mob

@export var healt_component: HealthComponent
@export var state_machine: StateMachine
@export var initial_state: State


func _ready() -> void:
	healt_component.health_depleted.connect(_detroy)
	state_machine.current_state = initial_state


func _take_damage(value: int) -> void:
	healt_component.take_damage(value)


func _detroy() -> void:
	EventBus.enemy.enemy_died.emit(self)
	queue_free()
