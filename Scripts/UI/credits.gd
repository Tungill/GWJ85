extends Control
class_name Credits

const DEFAULT_POSITION_X: float = 0.0

@export_category("Animations")
@export var background: NinePatchRect
@export var container: MarginContainer

var background_size: Vector2

func _ready() -> void:
	self.visible = false
	#region ANIMATIONS
	background_size = background.size
	var pre_animation_position_x: float = -background_size.x
	background.position.x = pre_animation_position_x
	container.position.x = pre_animation_position_x
	#endregion

func open_pop_up() -> void:
	self.visible = true
	var tween: Tween = create_tween()
	tween.tween_property(background, "position", Vector2(0.0, background.position.y), 0.3).from_current().set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(container, "position", Vector2(0.0, container.position.y), 0.3).from_current().set_ease(Tween.EASE_OUT)

func close_pop_up() -> void:
	var pre_animation_position_x: float = -background_size.x
	var tween: Tween = create_tween()
	tween.tween_property(background, "position", Vector2(pre_animation_position_x, background.position.y), 0.5).from_current().set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(container, "position", Vector2(pre_animation_position_x, container.position.y), 0.5).from_current().set_ease(Tween.EASE_IN)
	await tween.finished
	self.visible = false
