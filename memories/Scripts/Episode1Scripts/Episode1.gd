extends Node
#settings open but buttons are not clickable

func _on_pause_button_pressed() -> void:
	# Проверяем, нет ли уже открытого меню, чтобы не плодить копии
	if get_tree().root.has_node("PauseMenu"):
		return

	var pause_menu = preload("res://MenusScenes/PauseMenu.tscn").instantiate()
	pause_menu.name = "PauseMenu" # Даем имя, чтобы легче было найти
	
	# Чтобы меню не съезжало, лучше добавить его в CanvasLayer
	var canvas = CanvasLayer.new()
	canvas.layer = 100
	get_tree().root.add_child(canvas)
	canvas.add_child(pause_menu)
	
	get_tree().paused = true # Замораживаем мир
