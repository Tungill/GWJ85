extends Control
class_name Debug

const FPS_MS: int = 16
@export var container: VBoxContainer
var properties: Array


func _ready() -> void:
	# Move itself on top of the screen at timeout to be visible over any existing screen.
	get_tree().create_timer(2.0).timeout.connect(
		func move_to_front() -> void: self.move_to_front()
		)
	self.visible = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_console_command") and OS.is_debug_build():
		self.visible = not self.visible
		get_viewport().set_input_as_handled() # Stop inputs from propagating down the SceneTree.

## Creates new debug properties in the UI, when called from other scripts. [br]
## Updates the value of an existing properties every [param time_in_frames] 
## if [method add_debug_property] is called in [method Node._process].
func add_debug_property(id: StringName, value: Variant, time_in_frames: int) -> void:
	var property_text: String = id + ": " + str(value)
	if properties.has(id):
		@warning_ignore("integer_division") # The following line triggers a Warning that can be ignored.
		if Time.get_ticks_msec() / FPS_MS % time_in_frames == 0:
			var target: Label = container.find_child(id, true, false)
			target.text = property_text
	else:
		var property: Label = Label.new()
		container.add_child(property)
		property.name = id
		property.text = property_text
		properties.append(id)

## Creates an horizontal line.
## Usefull to visually split debugs [member properties] into sections. [br]
## [color=yellow]WARNING:[/color] If this function is called in [method Node._process] it loops forever.
func add_separator() -> void:
	var separator: HSeparator = HSeparator.new()
	container.add_child(separator)
