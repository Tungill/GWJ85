extends Node2D
class_name RangeManager

const LEFT_RANGE_SUFFIX: String = " LeftRayCast"
const RIGHT_RANGE_SUFFIX: String = " RightRayCast"

@export var mob: Mob
@export var raycast: PackedScene

var state_machine: StateMachine
var attack_left_ranges: Dictionary[String, RangeRayCast]
var attack_right_ranges: Dictionary[String, RangeRayCast]


func _ready() -> void:
	state_machine = mob.state_machine
	for attack_key: String in state_machine.attack_states:
		_create_attack_range(state_machine.attack_states[attack_key])
	#region DEBUG
	print("Left Ranges: ", attack_left_ranges)
	print("Right Ranges: ", attack_right_ranges)
	#endregion
	
	for attack_key: String in attack_left_ranges:
		attack_left_ranges[attack_key].collision_begin.connect(_on_collision_begin)
		attack_left_ranges[attack_key].collision_stop.connect(_on_collision_stop)
	for attack_key: String in attack_right_ranges:
		attack_right_ranges[attack_key].collision_begin.connect(_on_collision_begin)
		attack_right_ranges[attack_key].collision_stop.connect(_on_collision_stop)


func _create_attack_range(attack: AttackState) -> void:
	var left_raycast: RangeRayCast = RangeRayCast.new()
	left_raycast.name = attack.name + LEFT_RANGE_SUFFIX
	add_child(left_raycast)
	left_raycast.target_position = Vector2( - attack.attack_range, 0)
	left_raycast.collision_mask = 1
	var right_raycast: RangeRayCast = RangeRayCast.new()
	right_raycast.name = attack.name + RIGHT_RANGE_SUFFIX
	add_child(right_raycast)
	right_raycast.collision_mask = 1
	right_raycast.target_position = Vector2(attack.attack_range, 0)
	
	attack_left_ranges[attack.name] = left_raycast
	attack_right_ranges[attack.name] = right_raycast


func _on_collision_begin(collider: Object, emittor: RangeRayCast) -> void:
	# TEST "and not mob.is_invulnerable" to no trigger state during Dodge
	if collider is PlayerCharacter and not mob.is_invulnerable:
		var attack_ranges: Dictionary
		var left_values: Array = attack_left_ranges.values()
		if left_values.has(emittor):
			attack_ranges = attack_left_ranges
		var right_values: Array = attack_right_ranges.values()
		if right_values.has(emittor):
			attack_ranges = attack_right_ranges
		var attack_name: String = attack_ranges.find_key(emittor)
		var attack_state: AttackState = state_machine.attack_states[attack_name]
		if attack_state.is_one_shot and attack_state.attack_count > 0:
			return
		state_machine.change_state_to(attack_state)


func _on_collision_stop(collider: Object, _emittor: RangeRayCast) -> void:
	# TEST "and not mob.is_invulnerable" to no trigger state during Dodge
	if collider is PlayerCharacter and not mob.is_invulnerable:
		var index: int
		for i: State in state_machine.states_list:
			if i is MoveState:
				index = state_machine.states_list.find(i)
		var move_state: MoveState = state_machine.states_list[index]
		state_machine.change_state_to(move_state)
