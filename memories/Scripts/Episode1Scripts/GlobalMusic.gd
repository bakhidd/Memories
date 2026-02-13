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
	# <-- 2. Если идет затухание, убиваем его, чтобы оно не выключило музыку позже
	if fade_tween and fade_tween.is_running():
		fade_tween.kill()
		
	if not FileAccess.file_exists(path):
		print("ОШИБКА: Файл не найден: ", path)
		return

	player.volume_db = 0 
	
	if player.stream and player.stream.resource_path == path:
		if not player.playing: player.play()
		return
	
	player.stream = load(path)
	player.play()

func fade_out(duration: float = 1.5):
	# <-- 3. Сохраняем твин в переменную
	fade_tween = create_tween()
	fade_tween.tween_property(player, "volume_db", -80, duration)
	
	await fade_tween.finished
	
	player.stop()
	player.volume_db = 0
