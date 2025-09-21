extends RigidBody2D
class_name  Mob

signal died

const DEATH_CLOUD: PackedScene = preload("res://Scenes/Enemies/Commons/death_cloud.tscn")

@export var healt_component: HealthComponent
@export var state_machine: StateMachine
@export var initial_state: State
@export var is_invulnerable: bool = false
@export var collision: CollisionShape2D
@export var sprite: Sprite2D
@export var audio_player: AudioStreamPlayer2D
@export_category("Audio")
@export var sfx_damage_received: AudioStream = preload("res://Audios/Enemy Hit 1.mp3")
@export var sfx_death: AudioStream = preload("res://Audios/Enemy Death 1.mp3")

func _ready() -> void:
	healt_component.health_depleted.connect(_detroy)
	
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
	audio_player.stream = sfx_damage_received
	audio_player.play()
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "self_modulate", Color.FIREBRICK, 0.05)
	tween.tween_property(sprite, "self_modulate", Color.WHITE, 0.05)


func _detroy() -> void:
	state_machine.is_dead = true
	EventBus.enemy.enemy_died.emit(self)
	emit_signal("died")
	audio_player.stream = sfx_death
	audio_player.play()
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.5).from_current()
	var death_effect: Sprite2D = DEATH_CLOUD.instantiate()
	death_effect.position.y = (collision.shape.get_rect().size.y /2)
	add_child(death_effect)
	await  death_effect.animation_finished
	queue_free()


func _get_dodge_state() -> DodgeState:
	for i: State in state_machine.states_list:
		if i is DodgeState:
			return i
	return null


#region DEBUG
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_action_2") and OS.is_debug_build():
		self.take_damage(1)
#endregion
