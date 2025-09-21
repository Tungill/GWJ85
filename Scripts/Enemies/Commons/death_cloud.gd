extends Sprite2D

signal animation_finished

@export var animation_player: AnimationPlayer

func _ready() -> void:
	animation_player.play("spawning")
	await  animation_player.animation_finished
	var tween: Tween = create_tween()
	tween.tween_property(self, "modulate", Color(self.modulate, 0.0), 0.5)
	await tween.finished
	animation_finished.emit()
	self.queue_free()
