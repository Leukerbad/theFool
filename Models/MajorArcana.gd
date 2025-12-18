class_name MajorArcana

var id: String
var name_key: String
var description_key: String
var params: Dictionary = {}


func modify_trigger_count(player, base_triggers: int) -> int:
	if params.has("fixed_trigger_count"):
		return params.fixed_trigger_count
	return base_triggers


func before_trigger(player, trigger_index: int, context: Dictionary) -> void:
	if params.has("repeat_first_trigger") and trigger_index == 0:
		context["repeat_trigger"] = params.repeat_first_trigger


func after_trigger(player, trigger_index: int, context: Dictionary) -> void:
	pass


func modify_power(player, power: int) -> int:
	if params.has("power_multiplier"):
		return power * params.power_multiplier
	return power
