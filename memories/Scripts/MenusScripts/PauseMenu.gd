extends Node


func _on_controls_button_pressed() -> void:
	_open_sub_menu("res://MenusScenes/Controls.tscn")

func _on_audio_button_pressed() -> void:
	_open_sub_menu("res://MenusScenes/Audio.tscn")

func _on_graphics_button_pressed() -> void:
	_open_sub_menu("res://MenusScenes/Graphics.tscn")

# Универсальная функция для открытия окон поверх паузы
func _open_sub_menu(path: String):
	var sub_menu = load(path).instantiate()
	# Убеждаемся, что подменю тоже будет работать на паузе
	sub_menu.process_mode = Node.PROCESS_MODE_ALWAYS 
	add_child(sub_menu)


func _on_back_button_pressed() -> void:
	get_tree().paused = false # Оживляем игру
	
	# Если мы добавляли меню в CanvasLayer (как в коде выше), 
	# нам нужно удалить CanvasLayer, который является родителем этого меню
	if get_parent() is CanvasLayer:
		get_parent().queue_free()
	else:
		queue_free() # Если CanvasLayer не было, удаляем просто само меню

	
func _on_exit_to_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/MainMenu.tscn')


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			pass
		1:
			pass
			

	


func _on_exit_to_main_menu_button_2_pressed() -> void:
	get_tree().change_scene_to_file('res://MenusScenes/MainMenu.tscn')
