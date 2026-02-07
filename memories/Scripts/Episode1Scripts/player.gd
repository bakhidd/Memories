extends CharacterBody2D

const SPEED = 300.0
@onready var sprite = $Sprite2D
@onready var gun_tip = $Sprite2D/GunTip  # Точка, откуда вылетают пули

# Загружаем сцену пули
var bullet_scene = preload("res://Episodes1/bullet.tscn")

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

func shoot():
	var bullet = bullet_scene.instantiate()
	
	# Направление от игрока к мыши
	var mouse_pos = get_global_mouse_position()
	var shoot_direction = (mouse_pos - global_position).normalized()
	
	# Настраиваем пулю
	bullet.direction = shoot_direction
	
	# Спавним пулю в точке GunTip (если она есть), иначе в центре игрока
	if gun_tip:
		bullet.global_position = gun_tip.global_position
	else:
		bullet.global_position = global_position + shoot_direction * 40  # Смещение на 40 пикселей
	
	# Добавляем пулю в корневую сцену
	get_tree().root.add_child(bullet)
