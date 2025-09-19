extends RigidBody2D
class_name  Mob

@export var healt_component: HealthComponent
@export var state_machine: StateMachine
@export var initial_state: State
@export var is_invulnerable: bool = false : 
	set(value): 
		print("is_invulnerable: ", value)
		return value
@export var move_towards: MoveState.Direction

func _ready() -> void:
	healt_component.health_depleted.connect(_detroy)
	
	state_machine.change_movement_direction(move_towards)
	state_machine.current_state = initial_state
	lock_rotation = true



func take_damage(value: int) -> void:
	if is_invulnerable:
		return
	var dodge_state: DodgeState = _get_dodge_state()
	if dodge_state != null and dodge_state.dodge_count > 0:
		state_machine.change_state_to(dodge_state)
		return
	healt_component.take_damage(value)


func _detroy() -> void:
	EventBus.enemy.enemy_died.emit(self)
	queue_free()


func _get_dodge_state() -> DodgeState:
	for i: State in state_machine.states_list:
		if i is DodgeState:
			return i
	return null


#region DEBUG
#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("debug_action_2") and OS.is_debug_build():
		#self._take_damage(1)
#endregion
