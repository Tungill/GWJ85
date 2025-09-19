extends CharacterBody2D
class_name PlayerCharacter

@export_category("Essentials")
@export var health_component: HealthComponent

@export var sprite : Sprite2D
@export var left_attack : Area2D
@export var right_attack : Area2D
@export var cooldown_timer: Timer
@export_category("Parameters")
@export var base_step: float = 100   # base lunge distance
@export var lunge_time: float = 1.5  # how long the lunge lasts
@export var attack_duration: float = 0.5  # how long the attack lasts
@export var attack_cooldown: float = 1.0
@export var attack_damage: int = 1

var target_x: float # used to set relative x position for lunge
var tween: Tween
var step_size : float
var is_lunging: bool = false
var queued_direction: int = 0
var queued_flip: bool = false
var is_waiting_cooldown: bool = false
var is_alive: bool = true:
	# INFO Use the setter to trigger a signal if bool's value is false.
	set(value):
		if value == false:
			EventBus.player.player_died.emit()
			return false
var enemies_left_range: Array[Mob]
var enemies_right_range: Array[Mob]

func _ready() -> void:
	# INFO Change is_alive to false when the health from HealthComponent reaches 0.
	# Using a lambda function. Sets player character's relative x position
	health_component.health_depleted.connect(func change_is_alive() -> void: is_alive = false)
	EventBus.enemy.attack_hit_player.connect(take_damage)
	#region DEBUG
	if health_component == null:
		push_error("PlayerCharacter health component is not assigned.")
	#endregion

	step_size = base_step * scale.x  # proportional to character's size
	target_x = position.x
	cooldown_timer.timeout.connect(func _set_is_waiting_cooldown()-> void: is_waiting_cooldown = false)
	# Subscribe to AttackHitbox collision event to detetec when entering an enemy
	left_attack.body_entered.connect(_on_collision_enter.bind(true))
	left_attack.body_exited.connect(_on_collision_exit.bind(true))
	right_attack.body_entered.connect(_on_collision_enter.bind(false))
	right_attack.body_exited.connect(_on_collision_exit.bind(false))


func _physics_process(_delta: float) -> void:
	if not is_alive:
		return
	
	if Input.is_action_just_pressed("attack_left") and not is_waiting_cooldown:
		handle_input(-1, true, step_size)
	elif Input.is_action_just_pressed("attack_right") and not is_waiting_cooldown:
		handle_input(1, false, step_size)
		
	velocity.y = 0
	move_and_slide() # NOTICE Unsused?
	
	#region DEBUG
	DebugPanel.add_debug_property("Player HP", health_component.health, 10)
	DebugPanel.add_debug_property("Player Cooldown", snappedf(cooldown_timer.time_left, 0.01), 1)
	#endregion

func handle_input(direction: int, flip: bool, step_size: float) -> void:
	# INFO flip = false = right, flip = true = left,
	if is_lunging:
		#region TESTING Disabling queued lunge to avoid spamming attacks.
		# INFO Handles player input where it queues the next lunge if client
		# lunges again during another lunge motion
		#queued_direction = direction
		#queued_flip = flip
		#endregion
		return
	else:
		start_lunge(position.x + direction * step_size, flip)

func start_lunge(new_target: float, flip: bool) -> void:
	is_lunging = true
	target_x = new_target
	
	sprite.flip_h = flip
	tween = create_tween()
	tween.tween_property(self, "position:x", target_x, lunge_time) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)
	
	start_attack(flip)


func start_attack(left_side: bool) -> void:
	# Get the closest enemy on the list.
	var enemy: Mob
	match left_side:
		true:
			# If the attack missed and touched no enemies. Enter cooldown.
			if enemies_left_range.is_empty():
				_on_attack_failed()
				return
			enemy = enemies_left_range.front()
		false:
			# If the attack missed and touched no enemies. Enter cooldown.
			if enemies_right_range.is_empty():
				_on_attack_failed()
				return
			enemy = enemies_right_range.front()
	# If the attack succeded. Inflict damage and skip the cooldown timer.
	enemy.take_damage(attack_damage)
	_on_lunge_finished()


func take_damage(value: int) -> void:
	health_component.take_damage(value)
	# Trigger visual impact on damage.


func _on_lunge_finished() -> void: 
	is_lunging = false
	#region TESTING Disabling queued lunge to avoid spamming attacks.
	# INFO When lunge ends, it will queue another lunge even if 
	# the lunge in motion was queued or unqueued
	#if queued_direction != 0:
		#start_lunge(position.x + queued_direction * step_size, queued_flip)
		#queued_direction = 0
	#endregion


func _start_cooldown() -> void:
	is_waiting_cooldown = true
	cooldown_timer.start(attack_cooldown)

func _on_attack_failed() -> void:
	_on_lunge_finished()
	_start_cooldown()


# Add enemies to a list (left/right) 
func _on_collision_enter(body: Node2D, left_side: bool) -> void:
	if body is Mob:
		var mob: Mob = body
		match left_side:
			true:
				enemies_left_range.append(mob)
				print("Left range: ", enemies_left_range)
			false:
				enemies_right_range.append(mob)
				print("Right range: ", enemies_right_range)

# Remove enemies from a list (left/right) 
func _on_collision_exit(body: Node, left_side: bool) -> void:
	if body is Mob:
		var mob: Mob = body
		match left_side:
			true:
				enemies_left_range.pop_at(enemies_left_range.find(mob))
				print("Left range: ", enemies_left_range)
			false:
				enemies_right_range.pop_at(enemies_right_range.find(mob))
				print("Right range: ", enemies_right_range)
