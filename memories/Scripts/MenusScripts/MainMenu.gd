extends Node


func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/StartMenu.tscn')


func _on_settings_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/SettingsMenu.tscn')


func _on_exit_button_pressed() -> void:
	get_tree().quit()
