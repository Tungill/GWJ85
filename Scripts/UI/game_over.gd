extends Control


@export var retry_button: TextureButton
@export var music_audio_player: AudioStreamPlayer
const GAME: PackedScene = preload("res://Levels/Game.tscn")

func _ready() -> void:
	self.visible = false
	EventBus.player.player_died.connect(_on_game_over)
	retry_button.pressed.connect(_on_retry_pressed)


func _on_game_over() -> void:
	self.visible = true
	get_tree().paused = true


func _on_retry_pressed() -> void:
	# FIXME Triggers an error. SHould be the correct way to do it.
	#get_tree().change_scene_to_packed(GAME) 
	get_tree().reload_current_scene()
