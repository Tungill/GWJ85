extends Control

@export var start_over_button: TextureButton
@export var music_audio_player: AudioStreamPlayer
@export var color_rect: ColorRect
@export var background: TextureRect

const GAME: PackedScene = preload("res://Levels/Game.tscn")
const FADE_IN_DURATION: float = 3.0
const FADE_OUT_DURATION: float = 5.0

func _ready() -> void:
	self.visible = false
	EventBus.player.player_win.connect(_on_victory)
	start_over_button.pressed.connect(_on_start_over_pressed)
	color_rect.visible = false

func _on_transition_begin() -> void:
	color_rect.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(color_rect.color, 1.0), FADE_IN_DURATION).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(background, "position", Vector2(background.position.x, 0.0), 5.0)
	await  tween.finished

func _on_transition_end() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(color_rect.color, 0.0), FADE_OUT_DURATION).set_ease(Tween.EASE_IN)
	await  tween.finished
	color_rect.visible = false

func _on_victory() -> void:
	_on_transition_begin()
	get_tree().paused = true
	self.visible = true
	_on_transition_end()

func _on_start_over_pressed() -> void:
	get_tree().reload_current_scene()
