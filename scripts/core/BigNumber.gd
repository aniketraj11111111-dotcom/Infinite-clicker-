class_name BigNumber
extends RefCounted

var mantissa: float = 0.0
var exponent: int = 0

func _init(m: float = 0.0, e: int = 0) -> void:
	mantissa = m
	exponent = e
	_normalize()

func _normalize() -> void:
	if mantissa == 0.0:
		exponent = 0
		return
	if is_nan(mantissa) or is_inf(mantissa):
		return

	var shift = floor(log10(abs(mantissa)))
	if shift != 0:
		mantissa /= pow(10.0, shift)
		exponent += int(shift)

static func from_string(val: String) -> BigNumber:
	var result = BigNumber.new()
	var parts = val.split("e")
	if parts.size() == 2:
		result.mantissa = parts[0].to_float()
		result.exponent = parts[1].to_int()
	else:
		result.mantissa = val.to_float()
		result.exponent = 0
	result._normalize()
	return result

static func from_float(val: float) -> BigNumber:
	return BigNumber.new(val, 0)

static func add(a: BigNumber, b: BigNumber) -> BigNumber:
	if a.mantissa == 0: return BigNumber.new(b.mantissa, b.exponent)
	if b.mantissa == 0: return BigNumber.new(a.mantissa, a.exponent)

	var max_exp = max(a.exponent, b.exponent)
	var a_scaled = a.mantissa * pow(10.0, a.exponent - max_exp)
	var b_scaled = b.mantissa * pow(10.0, b.exponent - max_exp)

	return BigNumber.new(a_scaled + b_scaled, max_exp)

static func sub(a: BigNumber, b: BigNumber) -> BigNumber:
	if b.mantissa == 0: return BigNumber.new(a.mantissa, a.exponent)
	if a.mantissa == 0: return BigNumber.new(-b.mantissa, b.exponent)

	var max_exp = max(a.exponent, b.exponent)
	var a_scaled = a.mantissa * pow(10.0, a.exponent - max_exp)
	var b_scaled = b.mantissa * pow(10.0, b.exponent - max_exp)

	return BigNumber.new(a_scaled - b_scaled, max_exp)

static func mul(a: BigNumber, b: BigNumber) -> BigNumber:
	return BigNumber.new(a.mantissa * b.mantissa, a.exponent + b.exponent)

static func div(a: BigNumber, b: BigNumber) -> BigNumber:
	if b.mantissa == 0:
		push_error("BigNumber: Division by zero")
		return BigNumber.new(0, 0)
	return BigNumber.new(a.mantissa / b.mantissa, a.exponent - b.exponent)

static func is_greater_than_or_equal(a: BigNumber, b: BigNumber) -> bool:
	if a.exponent > b.exponent: return a.mantissa > 0
	if a.exponent < b.exponent: return a.mantissa < 0
	return a.mantissa >= b.mantissa

func to_string() -> String:
	if exponent < 3:
		return str(mantissa * pow(10.0, exponent))
	if exponent < 6:
		return str(floor(mantissa * pow(10.0, exponent)))

	var suffixes = ["", "k", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc"]
	var suffix_idx = int(floor(exponent / 3))

	if suffix_idx < suffixes.size():
		var display_mantissa = mantissa * pow(10.0, exponent % 3)
		return "%.2f%s" % [display_mantissa, suffixes[suffix_idx]]
	else:
		return "%.2fe%d" % [mantissa, exponent]
