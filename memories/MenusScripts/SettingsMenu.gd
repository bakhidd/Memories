extends Node


func _on_controls_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/Controls.tscn')

func _on_audio_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/Audio.tscn')

func _on_graphics_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/Graphics.tscn')


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/MainMenu.tscn')


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			pass
		1:
			pass
