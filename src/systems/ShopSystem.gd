extends Node

class_name ShopSystem

const UPGRADES_DB: Dictionary = {
	"click_power_1": {
		"name": "Better Mouse",
		"base_cost": "10",
		"cost_growth": 1.5,
		"effect_type": "click_power",
		"base_effect": "1",
		"description": "Increases click power by 1."
	},
	"auto_clicker_1": {
		"name": "Auto Clicker",
		"base_cost": "50",
		"cost_growth": 1.15,
		"effect_type": "passive_income",
		"base_effect": "2",
		"description": "Generates 2 currency per second."
	}
}

func get_upgrade_cost(upgrade_id: String, level: int) -> BigNumber:
	if not UPGRADES_DB.has(upgrade_id):
		return BigNumber.from_float(0.0)

	var data: Dictionary = UPGRADES_DB[upgrade_id]
	var base_cost: BigNumber = BigNumber.from_string(data["base_cost"])
	var growth: float = pow(data["cost_growth"], level)

	return BigNumber.mul(base_cost, BigNumber.from_float(growth))

func can_afford(upgrade_id: String) -> bool:
	var level: int = GameState.get_upgrade_level(upgrade_id)
	var cost: BigNumber = get_upgrade_cost(upgrade_id, level)
	return BigNumber.is_greater_than_or_equal(GameState.currency, cost)

func buy_upgrade(upgrade_id: String) -> bool:
	if not UPGRADES_DB.has(upgrade_id):
		return false

	var level: int = GameState.get_upgrade_level(upgrade_id)
	var cost: BigNumber = get_upgrade_cost(upgrade_id, level)

	if GameState.spend_currency(cost):
		GameState.set_upgrade_level(upgrade_id, level + 1)
		apply_upgrade_effect(upgrade_id)
		return true

	return false

func apply_upgrade_effect(upgrade_id: String) -> void:
	var data: Dictionary = UPGRADES_DB[upgrade_id]
	var effect_amount: BigNumber = BigNumber.from_string(data["base_effect"])

	if data["effect_type"] == "click_power":
		GameState.click_power = BigNumber.add(GameState.click_power, effect_amount)
	elif data["effect_type"] == "passive_income":
		GameState.passive_income = BigNumber.add(GameState.passive_income, effect_amount)

func recalculate_all_effects() -> void:
	GameState.click_power = BigNumber.from_float(1.0)
	GameState.passive_income = BigNumber.from_float(0.0)

	for upgrade_id in UPGRADES_DB:
		var level: int = GameState.get_upgrade_level(upgrade_id)
		for i in range(level):
			apply_upgrade_effect(upgrade_id)
