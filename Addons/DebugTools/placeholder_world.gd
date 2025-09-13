@tool
# This script and the Scene attached are use for debug examples.
extends Node2D

# Imagine the game need to reference the player from the start somehow.
# We use @export to have a relative reference that doesn't risk to break.
@export var reference_player: CharacterBody2D = null

# This function use a condition to trigger a Warning int the editor's Scene tree.
# It displays the "String" written under the if: return[].
# You may need to reload the project for the editor to update and show the Warning.
func _get_configuration_warnings() -> PackedStringArray:
	if reference_player == null:
		return ["The reference to the player is empty."]
	return []

# Uncomment these lines if you want a placeholder properties displaying on DebugPanel.
#var text: String = "Arbitrary number"
#var number: int = 50
#func _process(_delta: float) -> void:
	#DebugPanel.add_debug_property(text, number, 60)
