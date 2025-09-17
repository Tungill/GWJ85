# CAUTION INFO This Scene "process_mode" is set to "process_mode: When Pause"
# This mean the Scene & code is ONLY working when the game is paused. IMPORTANT
extends Control
class_name PauseMenu

const CONFIG_PATH: StringName = "user://user_settings.cfg"
const DEFAULT_VOLUME: float = 50.0

@export var music_volume_slider: HSlider
@export var music_volume_value_label: Label
@export var sfx_volume_slider: HSlider
@export var sfx_volume_value_label: Label
#@export var close_button: Button # DEPRECATED
@export var save_button: Button
@export var credits_button: Button
@export var credits_popup: Credits

var config: ConfigFile = ConfigFile.new()


func _ready() -> void:
	self.visible = false
	#close_button.pressed.connect(_on_close_button_pressed) # DEPRECATED
	credits_button.pressed.connect(_on_credits_button_pressed)
	save_button.pressed.connect(_on_save_button_pressed)
	music_volume_slider.value_changed.connect(_on_music_volume_slider_changed)
	sfx_volume_slider.value_changed.connect(_on_sfx_volume_slider_changed)
	_load_settings()


func toogle_visibility() -> void:
	self.visible = !self.visible


func _create_default_settings() -> void:
	music_volume_slider.set_value(DEFAULT_VOLUME)
	sfx_volume_slider.set_value(DEFAULT_VOLUME)


func _save_settings() -> void:
	config.set_value("audio", "music volume", music_volume_slider.value)
	config.set_value("audio", "sfx volume", sfx_volume_slider.value)
	
	var error: Variant = config.save(CONFIG_PATH)
	if error != OK:
		printerr("Error saving settings: ", error)
	else:
		printerr("Settings saved")


func _load_settings() -> void:
	var error: Variant = config.load(CONFIG_PATH)
	if error != OK:
		printerr("Error loading settings: ", error)
		_create_default_settings()
		return
	# Values are updated using the existing config.
	music_volume_slider.value = config.get_value("audio", "music volume", DEFAULT_VOLUME)
	sfx_volume_slider.value = config.get_value("audio", "sfx volume", DEFAULT_VOLUME)


func _on_music_volume_slider_changed(value: float) -> void:
	music_volume_value_label.text = str(int(value))
	var volume_db: float = linear_to_db(value / music_volume_slider.max_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), volume_db)


func _on_sfx_volume_slider_changed(value: float) -> void:
	sfx_volume_value_label.text = str(int(value))
	var volume_db: float = linear_to_db(value / sfx_volume_slider.max_value)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), volume_db)


func _on_save_button_pressed() -> void:
	_save_settings()
	toogle_visibility()
	get_tree().paused = false


func _on_credits_button_pressed() ->void:
	credits_popup.toogle_visibility()


# DEPRECATED Not use anymore since Settings stopped use a close_button. 
# Allows to close the Setting screen without Saving the changes to the config file.
func _on_close_button_pressed() -> void:
	# Values are updated using the existing config.
	music_volume_slider.value = config.get_value("audio", "music volume", DEFAULT_VOLUME)
	sfx_volume_slider.value = config.get_value("audio", "sfx volume", DEFAULT_VOLUME)
	toogle_visibility()
