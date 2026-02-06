extends Node

@onready var brightness_overlay = $ColorRect
@onready var brightness_slider = $BrightnessLabel/HScrollBar
@onready var apply_button = $ApplyButton

var brightness_value := 0.0

func _ready():
	load_settings()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/SettingsMenu.tscn')


func _on_full_screen_button_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)


func _on_full_screen_button_2_pressed() -> void:
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _on_on_button_pressed() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)


func _on_off_button_pressed() -> void:
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

func _on_h_scroll_bar_value_changed(value):
	var inverted = 11.0 - value * 11
	brightness_overlay.modulate = Color(0, 0, 0, inverted)


func _on_apply_button_pressed() -> void:
	save_settings()

func save_settings():
	var config = ConfigFile.new()
	config.set_value("graphics", "brightness", brightness_value)
	config.set_value("graphics", "slider_value", brightness_slider.value)
	config.save("user://settings.cfg")
	
func load_settings():
	var config = ConfigFile.new()
	var err = config.load("user://settings.cfg")
	if err == OK:
		brightness_value = config.get_value("graphics", "brightness", 0.0)
		var slider_val = config.get_value("graphics", "slider_value", 0.5) # default center
		brightness_slider.value = slider_val
		brightness_overlay.modulate = Color(0, 0, 0, brightness_value)
	else:
		print("No settings file found, using defaults.")
		
		#brightness doesn't save + brightness should be saved for all screens/scenes
