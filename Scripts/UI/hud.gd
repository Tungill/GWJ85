extends Control

@export var pause_button: TextureButton
@export var pause_popup: PauseMenu 


func _ready() -> void:
	pause_button.pressed.connect(_on_pause_button_pressed)


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	pause_popup.toogle_visibility()
