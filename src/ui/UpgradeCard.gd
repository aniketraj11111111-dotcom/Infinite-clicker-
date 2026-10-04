extends PanelContainer

@onready var name_label: Label = %NameLabel
@onready var desc_label: Label = %DescLabel
@onready var buy_button: Button = %BuyButton

var upgrade_id: String
var shop_system: ShopSystem

func setup(id: String, shop: ShopSystem) -> void:
	upgrade_id = id
	shop_system = shop

	var data: Dictionary = shop_system.UPGRADES_DB[upgrade_id]
	name_label.text = data["name"]
	desc_label.text = data["description"]

	buy_button.pressed.connect(_on_buy_button_pressed)
	GameState.currency_changed.connect(_on_currency_changed)
	GameState.upgrades_changed.connect(_update_ui)

	_update_ui()

func _update_ui() -> void:
	var level: int = GameState.get_upgrade_level(upgrade_id)
	var cost: BigNumber = shop_system.get_upgrade_cost(upgrade_id, level)
	buy_button.text = "Buy (" + cost.to_string() + ")"
	_check_affordability()

func _on_currency_changed(_amount: BigNumber) -> void:
	_check_affordability()

func _check_affordability() -> void:
	var can_afford: bool = shop_system.can_afford(upgrade_id)
	buy_button.disabled = not can_afford

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
