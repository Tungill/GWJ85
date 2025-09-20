extends Control

const FADE_IN_DURATION: float = 1.0
const FADE_OUT_DURATION: float = 1.0

@export var color_rect: ColorRect


func _ready() -> void:
	self.visible = false
	color_rect.modulate.a = 0.0
	EventBus.background.transition_triggered.connect(_on_transition_begin)
	EventBus.background.background_changed.connect(_on_transition_end)


func _on_transition_begin() -> void:
	self.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(color_rect.color, 1.0), FADE_IN_DURATION).set_ease(Tween.EASE_OUT)
	await  tween.finished
	EventBus.background.transition_fade_in_finished.emit()


func _on_transition_end() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(color_rect, "modulate", Color(color_rect.color, 0.0), FADE_OUT_DURATION).set_ease(Tween.EASE_IN)
	await  tween.finished
	self.visible = false
