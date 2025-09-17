extends Control

@export var play_button: Button
@export var pause_button: TextureButton
@export var pause_popup: PauseMenu 


func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	pause_button.pressed.connect(_on_pause_button_pressed)

# TBD 
# Choice 1: Split MainMenu and Settings to be able to display them separately on the Game scene.
# -> if we want to have the gameplay running on the bakground of the menu.
# Choice 2: Using MainMenu as a separate Scene than Game. Then load the Game scene using # DEPRECATED lines.
# -> if we use another illustration for MainMenu's background.
func _on_play_button_pressed() -> void:
	self.visible = false


func _on_pause_button_pressed() -> void:
	get_tree().paused = true
	pause_popup.toogle_visibility()
