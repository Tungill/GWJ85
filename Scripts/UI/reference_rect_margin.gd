@tool
extends ReferenceRect
# NOTE process_mode must be turned to "Always" on teh ReferenceRect node using this script
# in order to be able to works on the PauseMenu screen.

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		var parent: Control = get_parent()
		if parent is MarginContainer:
			var margin: MarginContainer = parent
			_set_reference_rect(margin.size)

func _set_reference_rect(new_size: Vector2) -> void:
	if Engine.is_editor_hint():
		self.position = Vector2(0.0, 0.0)
		self.size = new_size
