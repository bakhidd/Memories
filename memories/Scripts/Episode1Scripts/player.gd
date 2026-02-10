extends CharacterBody2D

const SPEED = 300.0

# Параметры здоровья
@export var max_health: int = 100
var current_health: int = 100
@export var heal_cooldown: float = 10.0  # Кулдаун в секундах 
var can_heal: bool = true                # Флаг готовности способности
var heal_bar_ui: ProgressBar = null # Ссылка на полоску кулдауна


var quest_label: Label = null

@onready var sprite = $Sprite2D
@onready var gun_tip = $Sprite2D/GunTip if has_node("Sprite2D/GunTip") else null

# Загружаем сцену пули
var bullet_scene = preload("res://Episodes1/bullet.tscn")

# UI элементы
var health_bar_ui: ProgressBar = null

func _ready():
	# Добавляем игрока в группу
	add_to_group("player")
	
	# Устанавливаем начальное здоровье
	current_health = max_health
	
	# Создаём UI health bar
	create_health_bar_ui()

func _physics_process(delta):
	# Движение игрока
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	move_and_slide()
	
	# Поворот к мыши
	var mouse_pos = get_global_mouse_position()
	sprite.rotation = (mouse_pos - global_position).angle()
	
	# Стрельба
	if Input.is_action_just_pressed("shoot"):
		shoot()
		
	if Input.is_key_pressed(KEY_H) and can_heal and current_health < max_health:
		use_heal_ability()

func shoot():
	var bullet = bullet_scene.instantiate()
	
	# Направление от игрока к мыши
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - global_position).normalized()
	
	# Настраиваем пулю
	bullet.direction = shoot_direction
	
	# Пули игрока НЕ помечаем как вражеские (по умолчанию is_enemy_bullet = false)
	
	# Спавним пулю в точке GunTip
	if gun_tip:
		bullet.global_position = gun_tip.global_position
	else:
		bullet.global_position = global_position + shoot_direction * 40
	
	# Добавляем пулю в корневую сцену
	get_tree().root.add_child(bullet)

func take_damage(damage: int):
	current_health -= damage
	current_health = max(0, current_health)
	
	print("💔 Игрок получил урон ", damage, "! HP: ", current_health, "/", max_health)
	
	# Обновляем health bar
	update_health_bar()
	
	# Эффект получения урона (красная вспышка)
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	
	# Проверяем смерть
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health += amount
	current_health = min(current_health, max_health)
	update_health_bar()
	print("💚 Игрок вылечился на ", amount, "! HP: ", current_health, "/", max_health)

func die():
	print("💀 ИГРОК УМЕР!")
	sprite.modulate = Color(0.3, 0.3, 0.3)
	set_physics_process(false)
	
	# Создаем окно смерти
	show_death_screen()

func show_death_screen():
	var canvas = get_node("PlayerUI") # Ищем созданный ранее CanvasLayer
	
	var panel = PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.size = Vector2(300, 150)
	canvas.add_child(panel)
	
	var vbox = VBoxContainer.new()
	panel.add_child(vbox)
	
	var label = Label.new()
	label.text = "YOU DIED\nTry again"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(label)
	
	var btn_retry = Button.new()
	btn_retry.text = "Try again"
	btn_retry.pressed.connect(func(): get_tree().reload_current_scene())
	vbox.add_child(btn_retry)
	
	var btn_exit = Button.new()
	btn_exit.text = "Main menu"
	btn_exit.pressed.connect(func(): get_tree().change_scene_to_file("res://MenusScenes/MainMenu.tscn"))
	vbox.add_child(btn_exit)

func create_health_bar_ui():
	# Создаём CanvasLayer для UI (всегда сверху)
	var canvas_layer = CanvasLayer.new()
	canvas_layer.name = "PlayerUI"
	add_child(canvas_layer)
	
	# Создаём контейнер для health bar
	var health_container = Control.new()
	health_container.name = "HealthContainer"
	health_container.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	health_container.position = Vector2(-100, -50)  # Центр внизу
	canvas_layer.add_child(health_container)
	
	# Создаём ProgressBar
	health_bar_ui = ProgressBar.new()
	health_bar_ui.name = "HealthBar"
	health_bar_ui.size = Vector2(200, 20)  # Небольшой размер
	health_bar_ui.max_value = max_health
	health_bar_ui.value = current_health
	health_bar_ui.show_percentage = false
	
	# Стиль для фона (серый)
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.2)
	bg_style.border_width_left = 2
	bg_style.border_width_right = 2
	bg_style.border_width_top = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color(0, 0, 0)
	health_bar_ui.add_theme_stylebox_override("background", bg_style)
	
	# Стиль для заполнения (зелёный)
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(0, 0.8, 0)
	health_bar_ui.add_theme_stylebox_override("fill", fill_style)
	
	health_container.add_child(health_bar_ui)
	
	# Добавляем текст с HP
	var health_label = Label.new()
	health_label.name = "HealthLabel"
	health_label.position = Vector2(0, -25)
	health_label.size = Vector2(200, 20)
	health_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	health_label.add_theme_font_size_override("font_size", 14)
	health_label.text = str(current_health) + " / " + str(max_health)
	health_container.add_child(health_label)
	
	# Создаем контейнер для индикатора лечения
	var heal_container = Control.new()
	heal_container.name = "HealContainer"
	# Размещаем чуть ниже основной полоски здоровья
	heal_container.position = Vector2(0, 30) 
	health_container.add_child(heal_container)

	# Создаем ProgressBar для кулдауна (наш "квадратик")
	heal_bar_ui = ProgressBar.new()
	heal_bar_ui.size = Vector2(60, 30) # Форма небольшого прямоугольника/квадрата
	heal_bar_ui.position = Vector2(70, 0) # Центрируем под полоской HP
	heal_bar_ui.fill_mode = ProgressBar.FILL_BOTTOM_TO_TOP # Заполнение снизу вверх
	heal_bar_ui.show_percentage = false
	heal_bar_ui.max_value = heal_cooldown
	heal_bar_ui.value = heal_cooldown # Изначально заполнена (готово)
	
	# Стиль готовности (зеленоватый/синий)
	var heal_style = StyleBoxFlat.new()
	heal_style.bg_color = Color(0, 0.6, 0.8, 0.8) 
	heal_bar_ui.add_theme_stylebox_override("fill", heal_style)
	
	heal_container.add_child(heal_bar_ui)

	# Надпись "HEAL" поверх квадратика
	var heal_label = Label.new()
	heal_label.text = "HEAL"
	heal_label.size = heal_bar_ui.size
	heal_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	heal_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	heal_label.add_theme_font_size_override("font_size", 12)
	heal_bar_ui.add_child(heal_label)
	
	quest_label = Label.new()
	quest_label.name = "QuestLabel"
	quest_label.text = "Goal: Find the path to her heart..."
	quest_label.position = Vector2(-200, -500) # Настрой позицию, чтобы было видно в углу
	canvas_layer.add_child(quest_label)

func update_health_bar():
	if health_bar_ui:
		health_bar_ui.value = current_health
		
		# Обновление цвета (ваш существующий код) [cite: 15]
		var fill_style = health_bar_ui.get_theme_stylebox("fill") as StyleBoxFlat
		if current_health > max_health * 0.6:
			fill_style.bg_color = Color(0, 0.8, 0)
		elif current_health > max_health * 0.3:
			fill_style.bg_color = Color(1, 0.8, 0)
		else:
			fill_style.bg_color = Color(1, 0, 0)
			
		# ИСПРАВЛЕНИЕ: Прямое обновление текста через поиск узла в контейнере
		var label = health_bar_ui.get_parent().get_node("HealthLabel") as Label
		if label:
			label.text = str(current_health) + " / " + str(max_health) 

func use_heal_ability():
	can_heal = false
	heal(100) # [cite: 11]
	
	if heal_bar_ui:
		heal_bar_ui.value = 0 # Опустошаем визуально
		# Меняем цвет на тусклый во время отката
		heal_bar_ui.get_theme_stylebox("fill").bg_color = Color(0.3, 0.3, 0.3, 0.8)

	# Плавное заполнение полоски
	var tween = create_tween()
	tween.tween_property(heal_bar_ui, "value", heal_cooldown, heal_cooldown)
	
	# Ждем окончания отката
	await get_tree().create_timer(heal_cooldown).timeout
	
	can_heal = true
	if heal_bar_ui:
		# Возвращаем яркий цвет готовности
		heal_bar_ui.get_theme_stylebox("fill").bg_color = Color(0, 0.6, 0.8, 0.8)
	print("✅ Лечение снова доступно!")

func update_quest(new_text: String):
	if quest_label:
		quest_label.text = "Goal: " + new_text
