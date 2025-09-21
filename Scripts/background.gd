extends Node2D

@export var background: Sprite2D
@export var background_textures: Array[Texture2D]
@export var spawner: Node2D

var texture: CanvasTexture


func _ready() -> void:
	texture = background.texture
	texture.diffuse_texture = background_textures.pop_front()
	EventBus.background.transition_fade_in_finished.connect(change_background)

#region DEBUG
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_action_1") and OS.is_debug_build():
		EventBus.background.transition_triggered.emit()
#endregion


func change_background() -> void:
	if not background_textures.is_empty():
		texture.diffuse_texture = background_textures.pop_front()
		background.offset.y -= 35
	EventBus.background.background_changed.emit()
	if spawner:
		spawner.clear_enemies()
