extends CharacterBody2D

# Параметры врага
@export var speed: float = 150.0
@export var max_health: int = 100
@export var detection_range: float = 500.0
@export var attack_range: float = 400.0

# Параметры оружия
@export var fire_rate: float = 0.5
@export var bullet_speed: float = 400
@export var bullet_damage: int = 10
@export var spread: float = 0.05
@export var burst_count: int = 1
@export var burst_delay: float = 0.1

# Коррекция угла спрайта
@export var sprite_offset_angle: float = -PI/2

var current_health: int = 100
var player: Node2D = null
var can_shoot = true
var bullet_scene = preload("res://Episodes1/bullet.tscn")
var shoot_point: Marker2D = null
var raycast: RayCast2D = null
var health_bar: ProgressBar = null

@onready var sprite = $Sprite2D if has_node("Sprite2D") else null
@onready var shoot_sound = $ShootSound 

func _ready():
	# Устанавливаем начальное здоровье
	current_health = max_health
	add_to_group("enemies") 
	# Ищем игрока
	player = get_tree().get_first_node_in_group("player")
	
	# Ищем ShootPoint
	shoot_point = find_child("ShootPoint", true, false)
	
	if not shoot_point:
		shoot_point = Marker2D.new()
		shoot_point.name = "ShootPoint"
		shoot_point.position = Vector2(40, 0)
		add_child(shoot_point)
	
	# Создаём RayCast2D для проверки линии видимости
	raycast = RayCast2D.new()
	raycast.name = "VisionRaycast"
	raycast.enabled = true
	raycast.collide_with_areas = false
	raycast.collide_with_bodies = true
	raycast.hit_from_inside = false
	add_child(raycast)
	
	# Создаём health bar (маленький)
	create_health_bar()

func _physics_process(delta):
	if not player or player.current_health <= 0: 
		velocity = Vector2.ZERO
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Обнаружение игрока
	if distance_to_player < detection_range:
		# Проверяем линию видимости
		var can_see_player = check_line_of_sight()
		
		if can_see_player:
			if sprite:
				rotation = (player.global_position - global_position).angle() + sprite_offset_angle
			
			# Движемся к игроку, если далеко
			if distance_to_player > attack_range:
				var direction = (player.global_position - global_position).normalized()
				velocity = direction * speed
				move_and_slide()
			else:
				# Остановились и стреляем
				velocity = Vector2.ZERO
				if can_shoot:
					shoot()
		else:
			# Не видим игрока - останавливаемся
			velocity = Vector2.ZERO

func check_line_of_sight() -> bool:
	if not player or not raycast:
		return false
	
	raycast.target_position = to_local(player.global_position)
	raycast.force_raycast_update()
	
	if raycast.is_colliding():
		var collider = raycast.get_collider()
		if collider == player:
			return true
		else:
			return false
	
	return true

func shoot():
	if not shoot_point:
		return
	
	if not check_line_of_sight():
		return
		
	can_shoot = false
	shoot_sound.play()
	# Стреляем очередью
	for i in range(burst_count):
		if not check_line_of_sight():
			break
		
		if player and sprite:
			rotation = (player.global_position - global_position).angle() + sprite_offset_angle
		
		_spawn_bullet()
		
		if i < burst_count - 1:
			await get_tree().create_timer(burst_delay).timeout
	
	# Перезарядка
	await get_tree().create_timer(fire_rate).timeout
	can_shoot = true

func _spawn_bullet():
	if not shoot_point:
		return
		
	var bullet = bullet_scene.instantiate()
	
	var target_pos = player.global_position
	var direction = (target_pos - shoot_point.global_position).normalized()
	
	if spread > 0:
		var random_angle = randf_range(-spread, spread)
		direction = direction.rotated(random_angle)
	
	bullet.direction = direction
	bullet.speed = bullet_speed
	bullet.global_position = shoot_point.global_position
	
	# ВАЖНО: помечаем пулю как пулю врага
	if "damage" in bullet:
		bullet.damage = bullet_damage
	if "is_enemy_bullet" in bullet:
		bullet.is_enemy_bullet = true
	
	get_tree().root.add_child(bullet)

func take_damage(damage: int):
	current_health -= damage
	current_health = max(0, current_health)
	
	# Обновляем health bar
	update_health_bar()
	
	# Эффект урона (красная вспышка)
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	# Проверяем смерть
	if current_health <= 0:
		die()

func create_health_bar():
	health_bar = ProgressBar.new()
	health_bar.name = "HealthBar"
	
	# ИЗМЕНЕНИЕ: Сделали уже (25 вместо 30) и тоньше (2 вместо 4)
	health_bar.size = Vector2(25, 1) 
	
	# Центрируем над головой (смещение по X теперь -12.5, чтобы было ровно)
	health_bar.position = Vector2(-12.5, -35) 
	
	health_bar.max_value = max_health
	health_bar.value = current_health
	health_bar.show_percentage = false
	
	# Оставляем стили как были 
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.1, 0.1, 0.1, 0.6) # Сделали чуть прозрачнее
	health_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = Color(1, 0, 0)
	health_bar.add_theme_stylebox_override("fill", fill_style)
	
	add_child(health_bar)

func update_health_bar():
	if health_bar:
		health_bar.value = current_health
		
		# Меняем оттенок красного в зависимости от HP
		var fill_style = StyleBoxFlat.new()
		var health_percent = float(current_health) / float(max_health)
		fill_style.bg_color = Color(1, health_percent * 0.3, 0)  # От тёмно-красного к оранжевому
		health_bar.add_theme_stylebox_override("fill", fill_style)

func die():
	
	# Эффект смерти
	modulate = Color(0.5, 0.5, 0.5)
	
	# Удаляемся через небольшую задержку
	await get_tree().create_timer(0.3).timeout
	queue_free()
