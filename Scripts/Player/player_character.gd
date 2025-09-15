extends CharacterBody2D
class_name PlayerCharacter

@export var health_component: HealthComponent

@export var sprite : Sprite2D
@export var left_attack : Area2D
@export var right_attack : Area2D
@export var base_step: float = 100   # base lunge distance
@export var lunge_time: float = 1  # how long the lunge lasts
@export var attack_duration: float = 0.3  # how long the attack lasts
@export var base_hitbox_offset: float = 16.0  # hitbox offset to relative position

var gravity : float = 1000 # default gravity value
var target_x: float # used to set relative x position for lunge
var tween: Tween
var step_size : float
var is_lunging: bool = false
var queued_direction: int = 0
var queued_flip: bool = false
var is_alive: bool = true:
	# INFO Use the setter to trigger a signal if bool's value is false.
	set(value):
		if value == false:
			EventBus.player.player_died.emit()

func _ready() -> void:
	# INFO Change is_alive to false when the health from HealthComponent reaches 0.
	# Using a lambda function. Sets player character's relative x position
	health_component.health_depleted.connect(func change_is_alive() -> void: is_alive = false)
	#region DEBUG
	if health_component == null:
		push_error("PlayerCharacter health component is not assigned.")
	
	health_component.health_changed.connect(
		func(old_health: int, new_health:int) -> void: 
			print("Old: ", old_health, " & New:", new_health)
			)
	#endregion

	step_size = base_step * scale.x  # proportional to character's size
	left_attack.get_node("CollisionShape2D").visible = false
	right_attack.get_node("CollisionShape2D").visible = false
	target_x = position.x

func _physics_process(delta: float) -> void:
	
	if Input.is_action_just_pressed("attack_left"):
		handle_input(-1, true, step_size)
	elif Input.is_action_just_pressed("attack_right"):
		handle_input(1, false, step_size)
	#velocity.y += gravity * delta
	move_and_slide()

func handle_input(direction: int, flip: bool, step_size: float) -> void:
	# INFO Handles player input where it queues the next lunge if client
	# lunges again during another lunge motion
	# flip = false = right, flip = true = left,
	if is_lunging:
		queued_direction = direction
		queued_flip = flip
	else:
		start_lunge(position.x + direction * step_size, flip)

func start_lunge(new_target: float, flip: bool) -> void:

	is_lunging = true
	target_x = new_target

	sprite.flip_h = flip

	start_attack(flip)

	tween = create_tween()
	tween.tween_property(self, "position:x", target_x, lunge_time) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)

	tween.finished.connect(_on_lunge_finished)

func _on_lunge_finished() -> void: 
	# INFO When lunge ends, it will queue another lunge even if 
	# the lunge in motion was queued or unqueued
	is_lunging = false
	if queued_direction != 0:
		start_lunge(position.x + queued_direction * step_size, queued_flip)
		queued_direction = 0

func start_attack(flip: bool) -> void:
	var hit_collision : CollisionShape2D
	var attack_hit_box: Area2D
	
	if not flip:
		attack_hit_box = right_attack
	else:
		attack_hit_box = left_attack
	
	hit_collision = attack_hit_box.get_node("CollisionShape2D")
	attack_hit_box.monitoring = true
	hit_collision.visible = true
#
	## TBD Emit attack signal and enemy takes damage from the hit.
#
	## Disable hitbox after attack_duration
	var timer :Timer = Timer.new()
	timer.wait_time = attack_duration
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(func turn_off_hitbox() -> void: 
		attack_hit_box.monitoring = false
		hit_collision.visible = false
		timer.queue_free()
		)

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
