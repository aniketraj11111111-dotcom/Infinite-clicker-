extends Node

signal currency_changed(amount: BigNumber)
signal upgrades_changed

var currency: BigNumber = BigNumber.from_float(0.0)
var click_power: BigNumber = BigNumber.from_float(1.0)
var passive_income: BigNumber = BigNumber.from_float(0.0)

var upgrades: Dictionary = {}

var auto_save_timer: float = 0.0
const AUTO_SAVE_INTERVAL: float = 10.0

var offline_bonus: BigNumber = null

func _ready() -> void:
	if not SaveLoadSystem.load_game():
		# Initialize fresh game profile
		currency = BigNumber.from_float(0.0)
		click_power = BigNumber.from_float(1.0)
		passive_income = BigNumber.from_float(0.0)
		upgrades = {}

func _process(delta: float) -> void:
	if passive_income.mantissa > 0:
		var income_this_frame: BigNumber = BigNumber.mul(passive_income, BigNumber.from_float(delta))
		add_currency(income_this_frame)

	auto_save_timer += delta
	if auto_save_timer >= AUTO_SAVE_INTERVAL:
		auto_save_timer = 0.0
		SaveLoadSystem.save_game()

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveLoadSystem.save_game()

func add_currency(amount: BigNumber) -> void:
	currency = BigNumber.add(currency, amount)
	currency_changed.emit(currency)

func spend_currency(amount: BigNumber) -> bool:
	if BigNumber.is_greater_than_or_equal(currency, amount):
		currency = BigNumber.sub(currency, amount)
		currency_changed.emit(currency)
		return true
	return false

func click() -> void:
	add_currency(click_power)

func get_upgrade_level(upgrade_id: String) -> int:
	return upgrades.get(upgrade_id, 0)

func set_upgrade_level(upgrade_id: String, level: int) -> void:
	upgrades[upgrade_id] = level
	_recalculate_stats()
	upgrades_changed.emit()

func _recalculate_stats() -> void:
	# This will be populated by ShopSystem logic or we can calculate here.
	# For now, we will rely on ShopSystem to apply effects, but typical design
	# has GameState recalculate from base + upgrade bonuses.
	# For simplicity, we assume ShopSystem applies effects directly or we calculate them here.
	# Let's emit a signal so ShopSystem or others know to recalculate
	pass
