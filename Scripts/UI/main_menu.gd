extends Control

@export var play_button: Button
@export var menu_panel: PanelContainer

var tween: Tween = null
var has_mouse_entered: bool = false


func _ready() -> void:
	play_button.pressed.connect(_on_play_button_pressed)
	menu_panel.mouse_entered.connect(func _on_mouse_entered()-> void: has_mouse_entered = true)
	menu_panel.mouse_exited.connect(func _on_mouse_exited()-> void: has_mouse_entered = false)

func _process(delta: float) -> void:
	if tween == null:
		_fade_play_button()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack_left") or event.is_action_pressed("attack_right"):
		if has_mouse_entered:
			_on_play_button_pressed()

# TBD 
# Choice 1: Split MainMenu and Settings to be able to display them separately on the Game scene.
# -> if we want to have the gameplay running on the bakground of the menu.
# Choice 2: Using MainMenu as a separate Scene than Game. Then load the Game scene using # DEPRECATED lines.
# -> if we use another illustration for MainMenu's background.
func _on_play_button_pressed() -> void:
	self.visible = false
	get_tree().paused = false

func _fade_play_button() -> void:
	var fade_duration: float = 1.75
	tween = create_tween()
	tween.tween_property(play_button, "self_modulate", Color(1, 0), fade_duration).set_ease(Tween.EASE_IN)
	tween.tween_property(play_button, "self_modulate", Color(1, 1), fade_duration).set_ease(Tween.EASE_IN)
	await  tween.finished
	tween = null
