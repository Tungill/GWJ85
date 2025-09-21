extends Control

const HEART_FULL: CompressedTexture2D = preload("res://Assets/UI/T_Heart_Full.png")
const HEART_EMPTY: CompressedTexture2D = preload("res://Assets/UI/T_Heart_Empty.png")

@export var pause_button: TextureButton
@export var pause_popup: PauseMenu 
@export var health_point: Control
@export var health_rect: TextureRect
@export var health_label: Label


func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)
	EventBus.player.health_changed.connect(_on_health_changed)


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	pause_popup.toogle_visibility()


func _on_health_changed(_old_value: int, new_value: int) -> void:
	_update_health_points(new_value)


func _update_health_points(new_value: int) -> void:
	health_rect.texture = HEART_EMPTY
	var tween: Tween = create_tween()
	tween.tween_property(health_point, "scale", Vector2(1.2, 1.2), 0.25)
	tween.tween_property(health_point, "scale", Vector2(1.0, 1.0), 0.25)
	health_label.text = str(new_value)
	await  tween.finished
	health_rect.texture = HEART_FULL
