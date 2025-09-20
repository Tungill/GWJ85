# CAUTION There should only be 1 DodgeState node per entity.
extends State
class_name DodgeState

enum Screen_side {LEFT, RIGHT}
const UPWARD_OFFSET: int = 100

@export_category("Parameters")
# BUG If the range is too small and RangeManager's raycast detect the player before _on_exit()
# then the Mob is stuck in MoveState untill the player leave then enter again a raycast. 
# Need to be fixed in RangeManager.
@export var distance_from_target: float = 50.0 
@export var max_dodge: int = 1
@export var is_cautious: bool = false # TODO find a better name for this option.
@export var dodge_duration: float = 1.0
@export_category("Essentials")
@export var move_component: MoveState
@export var mob: Mob

var dodge_count: int
var planned_position: Vector2
## If [member MoveState.move_direction] is to the [param LEFT], 
## then the entity is on the [param RIGHT] of the screen.
var side_directions: Dictionary[DodgeState.Screen_side, Vector2] = {
	Screen_side.LEFT: Vector2.LEFT,
	Screen_side.RIGHT: Vector2.RIGHT,
}
@export var target_side: Screen_side


func _ready() -> void:
	dodge_count = max_dodge


func _on_enter() -> void:
	mob.is_invulnerable = true
	_on_dodge()


func _on_dodge() -> void:
	# Target the point from opposite Side, distance_from the player.
	var player: PlayerCharacter = get_tree().get_first_node_in_group("Player")
	var player_collision_size: float = player.hitbox.shape.get_rect().size.x
	var mob_collision_size: float = mob.collision.shape.get_rect().size.x
	var planned_side: Screen_side
	# NOTE Distance is relative to the PlayerCharacter size and Self size.
	var distance: float = distance_from_target + (player_collision_size/2) + (mob_collision_size/2)
	if is_cautious:
		planned_side = _get_random_side()
		distance = distance_from_target * 2
	else:
		planned_side = _get_opposite_side_from(player)
	var offset_distance: Vector2 = side_directions[planned_side] * distance
	var player_position: Vector2 = player.global_position
	var upward_offset: Vector2 = Vector2(mob.global_position.x, mob.global_position.y - UPWARD_OFFSET)
	planned_position = player_position + offset_distance
	# Move
	var first_half_duration: float = (dodge_duration * 1) /4
	var second_half_duration: float = (dodge_duration * 3) /4
	var first_tween: Tween = create_tween()
	first_tween.tween_property(mob, "global_position", upward_offset, first_half_duration)
	await first_tween.finished
	var second_tween: Tween = create_tween()
	second_tween.tween_property(mob, "global_position", planned_position, second_half_duration).set_ease(Tween.EASE_IN_OUT)
	await second_tween.finished
	dodge_count -= 1
	# Update the Move Direction from the new position.
	_set_new_move_direction(player)
	# Return to initial state.
	mob.state_machine.change_state_to(mob.initial_state)


func _on_exit() -> void:
	mob.is_invulnerable = false


func _get_side_relative_to_target(target: Object) -> Screen_side:
	var current_side_from_target: Screen_side
	var target_position: Vector2 = target.global_position
	if mob.global_position.x > target_position.x:
		current_side_from_target = Screen_side.RIGHT
	elif mob.global_position.x < target_position.x:
		current_side_from_target = Screen_side.LEFT
	return current_side_from_target


# Reverse the value from current_side relative to the target.
func _get_opposite_side_from(target: Object) -> Screen_side:
	var new_side: Screen_side
	var current_side: Screen_side = _get_side_relative_to_target(target)
	match current_side:
		Screen_side.LEFT:
			new_side = Screen_side.RIGHT
		Screen_side.RIGHT:
			new_side = Screen_side.LEFT
	return new_side


func _get_random_side() -> Screen_side:
	var random_side: Screen_side = Screen_side[Screen_side.keys().pick_random()]
	return random_side


func _set_new_move_direction(target: Object) -> void:
	var new_direction: MoveState.Direction
	var current_side: Screen_side = _get_side_relative_to_target(target)
	match current_side:
		Screen_side.LEFT:
			new_direction = MoveState.Direction.RIGHT
		Screen_side.RIGHT:
			new_direction = MoveState.Direction.LEFT
	mob.state_machine.change_movement_direction(new_direction)
