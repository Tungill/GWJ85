extends Node2D


func _ready() -> void:
	get_tree().paused = true 
	var player : CharacterBody2D = get_tree().get_first_node_in_group("Player")
