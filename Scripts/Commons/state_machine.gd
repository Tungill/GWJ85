extends Node
class_name StateMachine

var states_list: Array[State]
var attack_states: Dictionary[StringName, AttackState]
var current_state: State;
var next_state: State;


func _ready() -> void:
	var children: Array = get_children(true)
	for child: Node in children:
		if child is State:
			states_list.append(child)
		if child is AttackState:
			attack_states[child.name] = child
	#region DEBUG
	#print(self.owner.name, "'s array of state(s): ", states_list)
	#print(self.owner.name, "'s dictionary of attack state(s): ", attack_states)
	#endregion


func _process(delta: float) -> void:
	if next_state != null:
		current_state._on_exit();
		current_state = next_state;
		current_state._on_enter();
		next_state = null;
	if current_state and current_state.has_method("_on_process"):
		current_state._on_process(delta);


func _physics_process(delta: float) -> void:
	if current_state and current_state.has_method("_on_physics_process"):
		current_state._on_physics_process(delta)


func change_state_to(new_state: State) -> void:
	next_state = new_state
	# DEBUG
	#print("Current State is: ", current_state, "Next State is: ", next_state)


func change_movement_direction(direction: MoveState.Direction) -> void:
	var index: int
	for i: State in states_list:
		if i is MoveState:
			index = states_list.find(i)
	var move_state: MoveState = states_list[index]
	move_state.move_direction = direction
