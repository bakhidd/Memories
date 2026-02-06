extends Node


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/MainMenu.tscn')


func _on_ep_1_button_pressed() -> void:
	get_tree().change_scene_to_file('res://Episodes1/Episode1.tscn')
