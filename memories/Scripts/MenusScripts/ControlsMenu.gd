extends Node


func _on_back_button_pressed() -> void:
	# Если у меню есть родитель (значит оно открыто как окно поверх паузы)
	if get_parent() is CanvasLayer or get_parent() != get_tree().root:
		queue_free() # Просто закрываем текущее подменю
	else:
		# Если оно открыто как отдельная сцена (из главного меню)
		get_tree().change_scene_to_file('res://MenusScenes/SettingsMenu.tscn')
