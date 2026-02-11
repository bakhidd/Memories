extends Area2D

@onready var flash = $CanvasLayer/Flash # Ссылка на белый прямоугольник
@onready var dialog_box = $CanvasLayer/ColorRect2 # Окно диалога
@onready var dialog_label = $CanvasLayer/Label# Текст

var active = false # Флаг: идет ли сейчас катсцена

var dialogue = [
	"Her: Unbelievable… Did you just flash me AGAIN?",
	"You: Strategic play.",
	"Her: You blinded your own teammate!",
	"You: Temporary sacrifice.",
	"Her: Bruh",
	"You: Hey. It got me here.",
	"You: Speaking of important things…",
	"You: Is 170 tall for you?",
	"Her: Still no.",
	"You: Damn. Valve nerfed me for real.",
	"Her: Hahahah! You can't blame Valve for your height.",
	"You: Watch me.",
	"You: Same time tomorrow?",
	"Her: Only if you don't flash me.",
	"You: No promises."
]

var current_line = 0
var is_typing = false

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.set_physics_process(false) # Замораживаем игрока
		start_cutscene()

func start_cutscene():
	# Эффект флешки
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
			# Останавливаем именно тот твин, который печатает текст 
			if typing_tween and typing_tween.is_running():
				typing_tween.kill() 
			dialog_label.visible_ratio = 1.0
			is_typing = false
		else:
			current_line += 1
			show_next_line()

func start_outro():
	dialog_box.visible = false
	# Создаем черный экран
	var black_out = ColorRect.new()
	black_out.color = Color(0, 0, 0, 0)
	black_out.set_anchors_preset(Control.PRESET_FULL_RECT)
	$CanvasLayer.add_child(black_out)
	
	var final_label = Label.new()
	final_label.text = "That day the match has ended,\nbut our story began."
	final_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	final_label.set_anchors_preset(Control.PRESET_CENTER)
	final_label.modulate.a = 0
	$CanvasLayer.add_child(final_label)
	
	var tween = create_tween()
	tween.tween_property(black_out, "color:a", 1.0, 2.0)
	tween.parallel().tween_property(final_label, "modulate:a", 1.0, 3.0)
