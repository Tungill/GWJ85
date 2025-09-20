extends Node2D

signal background_changed

const SCALE_MATCHING_TRANSITION: Vector2 = Vector2(0.6, 0.6)

@export var backgrounds: Array[Sprite2D]

var current_background: int = 0


func _ready() -> void:
	# Reset backgrounds values.
	for sprite: Sprite2D in backgrounds:
		sprite.modulate.a = 1
		sprite.visible = true

#region DEBUG
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_action_1") and OS.is_debug_build():
		change_background_transition(backgrounds[current_background+1])
#endregion

func change_background() -> void:
	change_background_transition(backgrounds[current_background+1])

func change_background_transition(new_background: Sprite2D) -> void:
	var sprite: Sprite2D = backgrounds[current_background]
	var tween: Tween = create_tween()
	tween.tween_property(sprite, "scale", SCALE_MATCHING_TRANSITION, 0.5).from_current()
	tween.tween_property(sprite, "modulate", Color(1, 0), 0.5)
	await tween.finished
	backgrounds[current_background].visible = false
	current_background = backgrounds.find(new_background) # Not sure it will works. Because all 3 are SPrite2D.
	background_changed.emit()
