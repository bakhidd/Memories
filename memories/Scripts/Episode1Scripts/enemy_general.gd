extends CharacterBody2D

# Параметры врага
@export var speed: float = 150.0
@export var health: int = 100
@export var detection_range: float = 500.0
@export var attack_range: float = 400.0

# Параметры оружия (настраиваются для каждого типа врага)
@export var fire_rate: float = 0.5  # Задержка между выстрелами
@export var bullet_speed: float = 400
@export var bullet_damage: int = 10
@export var spread: float = 0.05  # Разброс в радианах
@export var burst_count: int = 1  # Количество пуль за выстрел
@export var burst_delay: float = 0.1  # Задержка между пулями в очереди

var player: Node2D = null
var can_shoot = true
var bullet_scene = preload("res://Episodes1/bullet.tscn")
var shoot_point: Marker2D = null

@onready var sprite = $Sprite2D

func _ready():
	# Ищем игрока
	player = get_tree().get_first_node_in_group("player")
	
	if not player:
		print("⚠️ Игрок не найден!")
	
	# Ищем ShootPoint
	shoot_point = find_child("ShootPoint", true, false)
	
	if not shoot_point:
		shoot_point = Marker2D.new()
		shoot_point.name = "ShootPoint"
		shoot_point.position = Vector2(40, 0)
		add_child(shoot_point)
		print("✅ ShootPoint создан для ", name)

func _physics_process(delta):
	if not player:
		return
	
	var distance_to_player = global_position.distance_to(player.global_position)
	
	# Обнаружение игрока
	if distance_to_player < detection_range:
		# ПОВОРАЧИВАЕМ ВЕСЬ УЗЕЛ (CharacterBody2D), а не только спрайт!
		# Это повернёт и спрайт, и ShootPoint вместе
		rotation = (player.global_position - global_position).angle()
		
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

func shoot():
	if not shoot_point:
		print("❌ ShootPoint не найден у ", name)
		return
		
	can_shoot = false
	
	# Стреляем очередью
	for i in range(burst_count):
		# Поворачиваемся к игроку перед КАЖДЫМ выстрелом
		if player:
			rotation = (player.global_position - global_position).angle()
		
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
	
	# Направление с разбросом
	var target_pos = player.global_position
	var direction = (target_pos - shoot_point.global_position).normalized()
	
	if spread > 0:
		var random_angle = randf_range(-spread, spread)
		direction = direction.rotated(random_angle)
	
	bullet.direction = direction
	bullet.speed = bullet_speed
	bullet.global_position = shoot_point.global_position
	
	if "damage" in bullet:
		bullet.damage = bullet_damage
	
	get_tree().root.add_child(bullet)

func take_damage(damage: int):
	health -= damage
	# Эффект урона
	modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	modulate = Color.WHITE
	
	if health <= 0:
		die()

func die():
	queue_free()
