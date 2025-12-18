class_name Card

var id: String = ""
var name_key: String = ""
var description_key: String = ""
var type: String = ""
var position: String = ""
var position_effects: Dictionary = {}
var power: int

var destroyed: bool = false


func on_trigger(player : Player, trigger_index: int, stage: int, context: Dictionary, combat_log: CombatLog) -> void:
	if destroyed:
		return
	if not position_effects.has(position):
		return
	var effects: Dictionary = position_effects[position]
	_apply_effects(player, effects, trigger_index, stage, combat_log)


func _apply_effects(player : Player, effects: Dictionary, trigger_index: int, stage: int, combat_log: CombatLog) -> void:
	for effect_key in effects.keys():
		match effect_key:
			"power":
				var value := int(effects[effect_key])
				player.power += value
				combat_log.add_entry(
					stage,
					trigger_index,
					player.name,
					id,
					position,
					"gain_power",
					value
				)
			"add_trigger":
				var value := int(effects[effect_key])
				player.triggers += value
				combat_log.add_entry(
					stage,
					trigger_index,
					player.name,
					id,
					position,
					"gain_trigger",
					value
				)
			"duplicate_power":
				player.power *= 2
				combat_log.add_entry(
					stage,
					trigger_index,
					player.name,
					id,
					position,
					"duplicate_power",
					0
				)
			"destroy_self":
				if trigger_index >= int(effects[effect_key]):
					destroyed = true
					combat_log.add_entry(
						stage,
						trigger_index,
						player.name,
						id,
						position,
						"destroyed",
						0
					)
