extends Area2D

var speed = 600
var direction = Vector2.ZERO
var lifetime = 3.0  # Пуля живёт 3 секунды

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
	# Если пуля попала во что-то (врага, стену и т.д.)
	if body.name != "Player":  # Не попадаем в самого игрока
		queue_free()
