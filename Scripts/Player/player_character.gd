extends CharacterBody2D
class_name PlayerCharacter

@export var health_component: HealthComponent

@export var sprite : Sprite2D
@export var base_step: float = .05   # base lunge distance
@export var lunge_time: float = 0.25  # how long the lunge lasts (seconds)

var gravity : float = 1000 # default gravity value
var target_x: float # used to set relative x position for lunge
var tween: Tween
var is_lunging: bool = false
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

	target_x = position.x

func _physics_process(delta: float) -> void:
	
	var step_size : float = base_step * sprite.get_rect().size.x  # proportional to character's size

	if not is_lunging:
		if Input.is_action_just_pressed("attack_left"):
			start_lunge(position.x - step_size, true)
		elif Input.is_action_just_pressed("attack_right"):
			start_lunge(position.x + step_size, false)

	#velocity.y += gravity * delta
	move_and_slide()

func start_lunge(new_target: float, flip: bool) -> void:
	#if tween and tween.is_running():
		#tween.kill()  # cancel any ongoing tween

	is_lunging = true
	target_x = new_target

	sprite.flip_h = flip

	tween = create_tween()
	tween.tween_property(self, "position:x", target_x, lunge_time) \
		.set_trans(Tween.TRANS_EXPO) \
		.set_ease(Tween.EASE_OUT)

	tween.finished.connect(func _on_lunge_finished() -> void: is_lunging = false)

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
