class_name BattleEngine

const MAX_ROUNDS: int = 20

signal trigger_started(stage: int, trigger_index: int)
signal trigger_finished(stage: int, trigger_index: int, player_power: int, enemy_power: int)
signal battle_log(message: String)

func run_battle(player: Player, enemy: Player) -> Dictionary:
	var combat_log := CombatLog.new()

	player.reset_state()
	enemy.reset_state()

	var stage := 1
	while player.life > 0 and enemy.life > 0 and stage <= MAX_ROUNDS:
		_run_round(player, enemy, stage, combat_log)
		stage += 1

	return {
		"player_life": player.life,
		"enemy_life": enemy.life,
		"stages": stage,
		"combat_log": combat_log.entries
	}


func _run_round(player: Player, enemy: Player, stage: int, combat_log: CombatLog) -> void:
	_trigger_phase(player, stage, combat_log)
	_trigger_phase(enemy, stage, combat_log)
	_resolution_phase(player, enemy, stage, combat_log)
	_cleanup_phase(player)
	_cleanup_phase(enemy)


func _trigger_phase(player: Player, stage: int, combat_log: CombatLog) -> void:
	player.power = 0
	var base_triggers := player.triggers
	var arcana = player.deck.major_arcana
	var repeat_first := 0
	# Read repeat_first_trigger from Major Arcana params
	if arcana and arcana.params.has("repeat_first_trigger"):
		repeat_first = arcana.params.repeat_first_trigger
	for trigger_index in range(base_triggers):
		emit_signal("trigger_started", stage, trigger_index)
		emit_signal("battle_log", "Stage %d | Trigger %d | %s starts" % [stage, trigger_index, player.name])
		
		var context := {}
		if arcana:
			arcana.before_trigger(player, trigger_index, context)
		for card in player.deck.cards:
			card.on_trigger(player, trigger_index, stage, context, combat_log)
			emit_signal("battle_log", "Stage %d | Trigger %d | %s | %s -> power %d" % [stage, trigger_index, player.name, card.id, player.power])
		if arcana:
			arcana.after_trigger(player, trigger_index, context)
		emit_signal("trigger_finished", stage, 0, player.power, -1)
		emit_signal("battle_log", "Stage %d | Trigger %d (repeated) | %s ends | power %d" % [stage, 0, player.name, player.power])
	# Fire repeat_first_trigger from Major Arcana params
	for i in range(repeat_first):
		emit_signal("trigger_started", stage, 0)
		emit_signal("battle_log", "Stage %d | Trigger %d | %s starts" % [stage, 0, player.name])
		var context := {}
		if arcana:
			arcana.before_trigger(player, 0, context)
		for card in player.deck.cards:
			card.on_trigger(player, 0, stage, context, combat_log)
			emit_signal("battle_log", "Stage %d | Trigger %d (repeated) | %s | %s -> power %d" % [stage, 0, player.name, card.id, player.power])
		if arcana:
			arcana.after_trigger(player, 0, context)
		emit_signal("trigger_finished", stage, 0, player.power, -1)
		emit_signal("battle_log", "Stage %d | Trigger %d (repeated) | %s ends | power %d" % [stage, 0, player.name, player.power])


func _resolution_phase(player: Player, enemy: Player, stage: int, combat_log: CombatLog) -> void:
	combat_log.add_entry(stage, -1, player.name, "", "", "deal_damage", player.power)
	combat_log.add_entry(stage, -1, enemy.name, "", "", "deal_damage", enemy.power)
	var player_power := player.power
	var enemy_power := enemy.power
	if player.deck.major_arcana:
		player_power = player.deck.major_arcana.modify_power(player, player_power)
	if enemy.deck.major_arcana:
		enemy_power = enemy.deck.major_arcana.modify_power(enemy, enemy_power)
	player.life -= enemy_power
	enemy.life -= player_power
	emit_signal("battle_log", "Stage %d | Resolution | Player deals %d | Enemy deals %d" %[stage, player_power, enemy_power])
	emit_signal("trigger_finished", stage, -1, player_power, enemy_power)


func _cleanup_phase(actor: Player) -> void:
	actor.power = 0
	if actor.triggers > 5:
		actor.triggers -= 1
