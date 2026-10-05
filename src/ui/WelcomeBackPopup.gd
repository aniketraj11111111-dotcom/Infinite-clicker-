extends Control

@onready var message_label: Label = %MessageLabel
@onready var collect_button: Button = $Panel/VBoxContainer/HBoxContainer/CollectButton

func _ready() -> void:
	collect_button.pressed.connect(_on_collect_button_pressed)

	if GameState.offline_bonus != null:
		var amount_str: String = GameState.offline_bonus.to_string()
		message_label.text = "While you were away, your empire earned " + amount_str + " Cookies!"
		GameState.offline_bonus = null
	else:
		hide()

func _on_collect_button_pressed() -> void:
	hide()
	queue_free()
