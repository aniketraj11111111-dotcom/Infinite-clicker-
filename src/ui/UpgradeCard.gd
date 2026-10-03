extends PanelContainer

var upgrade_id: String
var shop_system: ShopSystem

func setup(id: String, shop: ShopSystem) -> void:
	upgrade_id = id
	shop_system = shop

	var data = shop_system.UPGRADES_DB[upgrade_id]
	%NameLabel.text = data["name"]
	%DescLabel.text = data["description"]

	%BuyButton.pressed.connect(_on_buy_button_pressed)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.upgrades_changed.connect(_update_ui)

	_update_ui()

func _update_ui() -> void:
	var level = GameState.get_upgrade_level(upgrade_id)
	var cost = shop_system.get_upgrade_cost(upgrade_id, level)
	%BuyButton.text = "Buy (" + cost.to_string() + ")"
	_check_affordability()

func _on_currency_changed(_amount: BigNumber) -> void:
	_check_affordability()

func _check_affordability() -> void:
	var can_afford = shop_system.can_afford(upgrade_id)
	%BuyButton.disabled = not can_afford

	if can_afford:
		modulate.a = 1.0
		# Simulated glow by changing self_modulate to slightly golden
		self_modulate = Color(1.1, 1.1, 0.9, 1.0)
	else:
		modulate.a = 0.6
		self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_buy_button_pressed() -> void:
	if shop_system.buy_upgrade(upgrade_id):
		AudioManager.play_upgrade_sound()
