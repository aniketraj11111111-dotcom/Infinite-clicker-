extends Control

var shop_system: ShopSystem

func _ready() -> void:
	GameState.currency_changed.connect(_on_currency_changed)
	%MainButton.button_down.connect(_on_main_button_down)
	%MainButton.button_up.connect(_on_main_button_up)

	_on_currency_changed(GameState.currency)

	# Instantiate popup
	var popup = load("res://src/ui/WelcomeBackPopup.tscn").instantiate()
	$WelcomeBackPopupLayer.add_child(popup)

	# Add upgrade cards (Shop System is stateless, we just use it for logic)
	shop_system = ShopSystem.new()
	add_child(shop_system)

	for upgrade_id in shop_system.UPGRADES_DB:
		var card = load("res://src/ui/UpgradeCard.tscn").instantiate()
		card.setup(upgrade_id, shop_system)
		%ShopVBox.add_child(card)

func _on_currency_changed(amount: BigNumber) -> void:
	%CurrencyLabel.text = "Cookies: " + amount.to_string()

func _on_main_button_down() -> void:
	AudioManager.play_click_sound()
	GameState.click()

	# Tween Press Animation
	var tween = create_tween()
	tween.tween_property(%MainButton, "scale", Vector2(0.95, 0.95), 0.05)

func _on_main_button_up() -> void:
	# Tween Release Animation with bounce
	var tween = create_tween()
	tween.tween_property(%MainButton, "scale", Vector2(1.0, 1.0), 0.2).set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
