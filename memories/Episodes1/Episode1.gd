extends Node
#settings open but buttons are not clickable

func _on_pause_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/PauseMenu.tscn')
