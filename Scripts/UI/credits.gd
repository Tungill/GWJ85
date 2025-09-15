extends Control
class_name Credits

@export var close_button: Button


func _ready() -> void:
	self.visible = false
	close_button.pressed.connect(toogle_visibility)


func toogle_visibility() -> void:
	self.visible = !self.visible
