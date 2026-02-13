# GlobalMusic.gd
extends Node

var player: AudioStreamPlayer
var fade_tween: Tween # <-- 1. Добавляем переменную для хранения твина

func _ready():
	player = AudioStreamPlayer.new()
	add_child(player)
	player.bus = "Master"
	player.process_mode = Node.PROCESS_MODE_ALWAYS 

func play_track(path: String):
	# УДАЛЯЕМ или КОММЕНТИРУЕМ эту проверку, она мешает в билде!
	# if not FileAccess.file_exists(path):
	# 	print("ОШИБКА: Файл не найден: ", path)
	# 	return

	player.volume_db = 0 
	
	if player.stream and player.stream.resource_path == path:
		if not player.playing: player.play()
		return
	
	# Пытаемся загрузить. Если файла нет, load вернет null, и игра не упадет
	var new_stream = load(path)
	if new_stream == null:
		print("Не удалось загрузить музыку: ", path)
		return

	player.stream = new_stream
	player.play()

func fade_out(duration: float = 1.5):
	# <-- 3. Сохраняем твин в переменную
	fade_tween = create_tween()
	fade_tween.tween_property(player, "volume_db", -80, duration)
	
	await fade_tween.finished
	
	player.stop()
	player.volume_db = 0
