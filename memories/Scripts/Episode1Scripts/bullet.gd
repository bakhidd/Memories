extends Area2D

var speed = 600
var direction = Vector2.ZERO
var lifetime = 3.0
var damage = 10

# Помечаем, чья это пуля
var is_enemy_bullet = false  # false = пуля игрока, true = пуля врага

func _ready():
	# Устанавливаем направление и поворот
	if direction != Vector2.ZERO:
		rotation = direction.angle()
	
	# Удаляем пулю через некоторое время
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	# Пуля просто движется вперёд
	position += direction * speed * delta

func _on_body_entered(body):
	# Если это пуля врага
	if is_enemy_bullet:
		# Попали в игрока?
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				print("💥 Пуля врага попала в игрока! Урон: ", damage)
			queue_free()
		# Попали в стену?
		elif not body.is_in_group("enemies"):
			queue_free()
	
	# Если это пуля игрока
	else:
		# Попали во врага?
		if body.is_in_group("enemies"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				print("💥 Пуля игрока попала во врага! Урон: ", damage)
			queue_free()
		# Попали в стену?
		elif not body.is_in_group("player"):
			queue_free()
