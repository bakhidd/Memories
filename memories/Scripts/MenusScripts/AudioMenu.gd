extends Node

func _on_master_volume_scroll_bar_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/SettingsMenu.tscn')
