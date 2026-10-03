extends Node

const SAVE_PATH = "user://infinite_save.dat"
const SECURE_KEY = "Sup3rS3cr3tS4v3K3y!123"

func save_game() -> void:
	var save_data = {
		"currency_m": GameState.currency.mantissa,
		"currency_e": GameState.currency.exponent,
		"click_power_m": GameState.click_power.mantissa,
		"click_power_e": GameState.click_power.exponent,
		"passive_income_m": GameState.passive_income.mantissa,
		"passive_income_e": GameState.passive_income.exponent,
		"upgrades": GameState.upgrades,
		"last_login_timestamp": Time.get_unix_time_from_system()
	}

	var json_string = JSON.stringify(save_data)
	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.WRITE, SECURE_KEY)
	if file:
		file.store_string(json_string)
		file.close()
	else:
		push_error("Failed to save game data.")

func load_game() -> bool:
	if not FileAccess.file_exists(SAVE_PATH):
		return false

	var file = FileAccess.open_encrypted_with_pass(SAVE_PATH, FileAccess.READ, SECURE_KEY)
	if not file:
		push_error("Failed to open save file for reading.")
		return false

	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var parse_result = json.parse(json_string)

	if parse_result != OK:
		push_error("JSON Parse Error: ", json.get_error_message())
		return false

	var save_data = json.data
	if typeof(save_data) != TYPE_DICTIONARY:
		push_error("Parsed JSON is not a dictionary.")
		return false

	if save_data.has("currency_m") and save_data.has("currency_e"):
		GameState.currency = BigNumber.new(float(save_data["currency_m"]), int(save_data["currency_e"]))
	if save_data.has("click_power_m") and save_data.has("click_power_e"):
		GameState.click_power = BigNumber.new(float(save_data["click_power_m"]), int(save_data["click_power_e"]))
	if save_data.has("passive_income_m") and save_data.has("passive_income_e"):
		GameState.passive_income = BigNumber.new(float(save_data["passive_income_m"]), int(save_data["passive_income_e"]))
	if save_data.has("upgrades"):
		GameState.upgrades = save_data["upgrades"]

	if save_data.has("last_login_timestamp"):
		var last_login: float = save_data["last_login_timestamp"]
		var current_time: float = Time.get_unix_time_from_system()
		var time_passed: float = current_time - last_login

		if time_passed > 60.0 and GameState.passive_income.mantissa > 0:
			var multiplier = BigNumber.from_float(time_passed * 0.5)
			var offline_earnings = BigNumber.mul(GameState.passive_income, multiplier)
			GameState.add_currency(offline_earnings)
			GameState.offline_bonus = offline_earnings

	return true
