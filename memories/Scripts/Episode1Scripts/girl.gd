extends Area2D

@onready var flash = $CanvasLayer/Flash # Ссылка на белый прямоугольник
@onready var dialog_box = $CanvasLayer/ColorRect2 # Окно диалога
@onready var dialog_label = $CanvasLayer/Label# Текст
@onready var flash_sound = $FlashangSound
var active = false # Флаг: идет ли сейчас катсцена
var final_label_ref: Label

var dialogue = [
	"Her: WOW... Did you just flash me AGAIN?",
	"You: Look — accidents happen.",
	"Her: Sure buddy",
	"You: Yo soo… is 170 tall for you?",
	"Her: No.",
	"You: Damn, brutal. Good job Riot Games",
	"You: Alright… I’ll win you over eventually.",
	"You: Same time tomorrow?",
	"Her: Only if you don't flash me.",
	"You: No promises."
]

var current_line = 0
var is_typing = false

var final_dialogue = [
	"That match has ended,\nbut our story has just begun.",
	"Out of all the paths,\nall the maps,\nall the possible worlds…",
	"I’m glad they all led me to you.",
	"Happy Valentine’s Day, ya rou7i ❤️",
    "Love you — always."
]
var final_line_index = 0
var is_final_phase = false # Флаг для переключения режима ввода

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.set_physics_process(false) # Замораживаем игрока
		start_cutscene()

func start_cutscene():
	# Эффект флешки
	flash_sound.play()
	active = true
	flash.visible = true
	flash.modulate.a = 1.0
	var tween = create_tween()
	# Плавно убираем белый экран за 1.5 секунды
	tween.tween_property(flash, "modulate:a", 0.0, 1.5)
	
	await tween.finished
	flash.visible = false
	dialog_box.visible = true
	show_next_line()

var typing_tween # Переменная для хранения ссылки на анимацию 

func show_next_line():
	if current_line < dialogue.size():
		is_typing = true
		dialog_label.text = dialogue[current_line]
		dialog_label.visible_ratio = 0.0
		
		var duration = dialogue[current_line].length() * 0.04
		
		# Сохраняем твин в переменную, чтобы иметь к нему доступ
		typing_tween = create_tween() 
		typing_tween.tween_property(dialog_label, "visible_ratio", 1.0, duration)
		
		await typing_tween.finished
		is_typing = false
	else:
		active = false # Выключаем управление в конце
		start_outro()

func _input(event):
	if active and event.is_action_pressed("ui_accept"):
		if is_typing:
			if typing_tween and typing_tween.is_running():
				typing_tween.kill()
			
			# Устанавливаем текст полностью
			if is_final_phase:
				# ИСПРАВЛЕНИЕ: Используем переменную-ссылку, а не путь
				if is_instance_valid(final_label_ref):
					final_label_ref.visible_ratio = 1.0
			else:
				dialog_label.visible_ratio = 1.0
			
			is_typing = false 
		else:
			if is_final_phase:
				final_line_index += 1
				show_final_line()
			else:
				current_line += 1 
				show_next_line()

func start_outro():
	is_final_phase = true
	active = true
	dialog_box.visible = false 
	
	# ЗВУК: Сначала запускаем затухание
	GlobalMusic.fade_out(0.5) 
	# Создаем черный фон
	var black_out = ColorRect.new()
	black_out.color = Color(0, 0, 0, 0)
	black_out.set_anchors_preset(Control.PRESET_FULL_RECT)
	$CanvasLayer.add_child(black_out)
	
	# Создаем текст и сохраняем ССЫЛКУ на него
	final_label_ref = Label.new()
	final_label_ref.set_anchors_preset(Control.PRESET_FULL_RECT) 
	final_label_ref.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_label_ref.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	final_label_ref.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	$CanvasLayer.add_child(final_label_ref) # Добавляем в дерево
	
	var tween = create_tween()
	tween.tween_property(black_out, "color:a", 1.0, 2.0) 
	
	# ЗВУК: Пока экран темнеет, включаем музыку (с исправленным play_track она зазвучит!)
	await get_tree().create_timer(1.2).timeout
	GlobalMusic.play_track("res://Sounds/music/GBEdited.wav")
	
	await tween.finished
	show_final_line()

func show_final_line():
	# Используем сохраненную ссылку вместо поиска по пути $CanvasLayer/...
	if not is_instance_valid(final_label_ref): 
		return

	if final_line_index < final_dialogue.size():
		is_typing = true
		final_label_ref.text = final_dialogue[final_line_index]
		final_label_ref.visible_ratio = 0.0
		
		var duration = final_dialogue[final_line_index].length() * 0.05
		typing_tween = create_tween()
		typing_tween.tween_property(final_label_ref, "visible_ratio", 1.0, duration)
		
		await typing_tween.finished
		is_typing = false
	else:
		get_tree().change_scene_to_file("res://MenusScenes/StartMenu.tscn")
