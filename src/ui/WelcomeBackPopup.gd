extends Control

func _ready() -> void:
	$Panel/VBoxContainer/HBoxContainer/CollectButton.pressed.connect(_on_collect_button_pressed)

	if GameState.offline_bonus != null:
		var amount_str = GameState.offline_bonus.to_string()
		%MessageLabel.text = "While you were away, your empire earned " + amount_str + " Cookies!"
		GameState.offline_bonus = null
	else:
		hide()

func _on_collect_button_pressed() -> void:
	hide()
	queue_free()
