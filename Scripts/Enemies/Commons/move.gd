# CAUTION There should only be 1 MoveState node per entity.
extends State
class_name MoveState

enum Direction {LEFT, RIGHT}

@export var mob: RigidBody2D
## WARNING [member speed] must be different from [param 0] to move.
@export var speed: float = 100
@export var move_direction: Direction
@export var audio_player: AudioStreamPlayer2D
@export_category("Animations")
@export var left_texture: Texture2D
@export var left_duration: float = 0.3
@export var right_texture: Texture2D
@export var right_duration: float = 0.3
@export var sfx_steps: AudioStream = preload("res://Audios/Enemy Step Loop.mp3")


var directions: Dictionary[Direction, Vector2] = {
	Direction.LEFT: Vector2.LEFT,
	Direction.RIGHT: Vector2.RIGHT
	}
var player: CharacterBody2D
# Animations
var timer_left: Timer
var timer_right: Timer


func _ready() -> void:
	player = get_tree().get_first_node_in_group("Player")
	#region Animations
	timer_left = Timer.new()
	timer_left.one_shot = true
	timer_left.process_callback = 0
	add_child(timer_left)
	timer_right = Timer.new()
	timer_right.one_shot = true
	timer_right.process_callback = 0
	add_child(timer_right)
	
	timer_left.timeout.connect(
		func _start_right_walking()->void: _change_texture(right_texture, timer_right, right_duration)
		)
	timer_right.timeout.connect(
		func _start_left_walking()->void: _change_texture(left_texture, timer_left, left_duration)
		)
	
	_change_texture(left_texture, timer_left, left_duration)
	#endregion


func _on_enter() -> void:
	_change_texture(left_texture, timer_left, left_duration)


func _on_physics_process(delta: float) -> void:
	# NOTE If the player get out of range, the MoveState should be called again
	if player: 
		if player.global_position.x < mob.global_position.x:
			move_direction = Direction.LEFT
		else:
			move_direction = Direction.RIGHT
	
	var direction: Vector2 = directions[move_direction]
	var motion: Vector2 = direction * speed * delta
	motion.y = 0
	mob.move_and_collide(motion)
	
	var sprite: Sprite2D = mob.get_node("Sprite2D") 
	sprite.flip_h = (move_direction == Direction.RIGHT)
	# DEBUG
	#print(mob.position, " Direction: ", direction, " Motion: ", motion)


func _on_exit() -> void:
	timer_left.stop()
	timer_right.stop()


func _change_texture(new_texture: Texture2D, timer: Timer, duration: float) -> void:
	if sprite.texture is not CanvasTexture:
		push_error(mob, "'s Sprite2D is not of type CanvasTexture.")
	var texture: CanvasTexture = sprite.texture as CanvasTexture
	texture.diffuse_texture = new_texture
	timer.start(duration)
	# Audio
	audio_player.stream = sfx_steps
	audio_player.play()
