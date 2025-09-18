# CAUTION There should only be 1 MoveState node per entity.
extends State
class_name MoveState

enum Direction {LEFT, RIGHT}

@export var mob: RigidBody2D
## WARNING [member speed] must be different from [param 0] to move.
@export var speed: float = 100
@export var move_direction: Direction

var directions: Dictionary[Direction, Vector2] = {
	Direction.LEFT: Vector2.LEFT,
	Direction.RIGHT: Vector2.RIGHT
	}


func _on_enter() -> void:
	pass


func _on_physics_process(delta: float) -> void:
	# TODO Move on a straigth line until being able to reach the player when attacking
	# NOTE If the player get out of range, the MoveState should be called again
	var direction: Vector2 = directions[move_direction]
	var motion: Vector2 = direction * speed * delta
	mob.move_and_collide(motion)
	# DEBUG
	#print(mob.position, " Direction: ", direction, " Motion: ", motion)


func _on_exit() -> void:
	pass
