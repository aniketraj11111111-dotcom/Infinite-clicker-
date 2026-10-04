extends Node

var click_player: AudioStreamPlayer = AudioStreamPlayer.new()
var upgrade_player: AudioStreamPlayer = AudioStreamPlayer.new()

func _ready() -> void:
	# Optional placeholder sound, user will drag and drop later.
	add_child(click_player)

	# Optional placeholder sound.
	add_child(upgrade_player)

func play_click_sound() -> void:
	click_player.pitch_scale = randf_range(0.9, 1.1)
	if click_player.stream != null:
		click_player.play()

func play_upgrade_sound() -> void:
	if upgrade_player.stream != null:
		upgrade_player.play()
