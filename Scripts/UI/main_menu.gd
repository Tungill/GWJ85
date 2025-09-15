extends Control

# TODO Copy Path of the game's Scene and past it between the "".
const GAME_SCENE_PATH: StringName = "" # DEPRECATED

@export var play_button: Button
@export var settings_button: Button
@export var settings_popup: Settings


func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	settings_button.pressed.connect(_on_settings_button_pressed)

# TBD 
# Choice 1: Split MainMenu and Settings to be able to display them separately on the Game scene.
# -> if we want to have the gameplay running on the bakground of the menu.
# Choice 2: Using MainMenu as a separate Scene than Game. Then load the Game scene using # DEPRECATED lines.
# -> if we use another illustration for MainMenu's background.
func _on_play_button_pressed() -> void:
	self.visible = false
	#get_tree().change_scene_to_file(GAME_SCENE_PATH) # DEPRECATED


func _on_settings_button_pressed() -> void:
	get_tree().paused = true
	settings_popup.toogle_visibility()
