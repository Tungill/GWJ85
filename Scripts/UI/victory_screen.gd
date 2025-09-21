extends Control

@export var start_over_button: TextureButton
@export var music_audio_player: AudioStreamPlayer
const GAME: PackedScene = preload("res://Levels/Game.tscn")

func _ready() -> void:
	self.visible = false
	EventBus.player.player_win.connect(_on_victory)
	start_over_button.pressed.connect(_on_start_over_pressed)

func _on_victory() -> void:
	self.visible = true
	get_tree().paused = true

func _on_start_over_pressed() -> void:
	# FIXME Triggers an error. SHould be the correct way to do it.
	#get_tree().change_scene_to_packed(GAME) 
	get_tree().reload_current_scene()
