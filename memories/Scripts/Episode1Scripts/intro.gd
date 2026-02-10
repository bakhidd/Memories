extends Control

var dialogues = [
	"Some paths are simple.",
	"Some are full of turns, shadows, and uncertainty.",
	"But if you keep moving forward",
	"you might find what matters most..."
]
var current_line = 0
var typing_speed = 0.05 # Скорость появления букв (чем меньше, тем быстрее)

@onready var text_label = $Label
@onready var next_button = $Button

func _ready():
	# Скрываем кнопку, пока текст печатается (по желанию)
	next_button.disabled = true
	show_text()

func show_text():
	if current_line < dialogues.size():
		text_label.text = dialogues[current_line]
		text_label.visible_ratio = 0.0 # Скрываем текст полностью
		
		# Создаем анимацию появления букв
		var duration = dialogues[current_line].length() * typing_speed
		var tween = create_tween()
		tween.tween_property(text_label, "visible_ratio", 1.0, duration)
		
		# Когда текст допечатается, включаем кнопку
		tween.finished.connect(func(): next_button.disabled = false)
	else:
		# Переход к самому уровню
		get_tree().change_scene_to_file("res://Episodes1/Episode1.tscn")

func _on_button_pressed():
	if text_label.visible_ratio < 1.0:
		# Если игрок нажал кнопку во время печати — показываем текст сразу
		var tween = create_tween() # Это остановит предыдущий твин, если нужно
		text_label.visible_ratio = 1.0
	else:
		# Иначе переходим к следующей фразе
		current_line += 1
		next_button.disabled = true
		show_text()
