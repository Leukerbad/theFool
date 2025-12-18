class_name BattleEngineNew

signal trigger_started(stage: int, trigger_index: int)
signal trigger_finished(stage: int, trigger_index: int)
signal battle_log(message: String)
signal battle_finished(result: Dictionary)
signal card_resolving(stage: int, trigger_index: int, actor: Player, card: Card)
signal damage_resolved(player_power: int, enemy_power: int, player_life: int, enemy_life: int)

const MAX_ROUNDS: int = 20

enum BattleState {
	INIT,
	STAGE_START,
	PLAYER_TRIGGER,
	ENEMY_TRIGGER,
	TRIGGER_CARD,
	RESOLUTION,
	CLEANUP,
	CHECK_END,
	FINISHED
}

var state: BattleState = BattleState.INIT
var stage := 1
var trigger_index := 0
var current_player: Player

var player: Player
var enemy: Player
var combat_log := CombatLog.new()

var resolving_player: Player
var resolving_context := {}
var card_index := 0
var resolving_arcana


func start(p: Player, e: Player):
	player = p
	enemy = e
	player.reset_state()
	enemy.reset_state()
	stage = 1
	state = BattleState.STAGE_START


func advance():
	match state:
		BattleState.STAGE_START:
			emit_signal("battle_log", "=== Stage %d ===" % stage)
			current_player = player
			trigger_index = 0
			state = BattleState.PLAYER_TRIGGER
		BattleState.PLAYER_TRIGGER:
			if _begin_trigger(player):
				state = BattleState.ENEMY_TRIGGER
				trigger_index = 0
		BattleState.ENEMY_TRIGGER:
			if _begin_trigger(enemy):
				state = BattleState.RESOLUTION
		BattleState.TRIGGER_CARD:
			_run_trigger_card()
		BattleState.RESOLUTION:
			_run_resolution()
			state = BattleState.CLEANUP
		BattleState.CLEANUP:
			_cleanup(player)
			_cleanup(enemy)
			state = BattleState.CHECK_END
		BattleState.CHECK_END:
			if player.life <= 0 or enemy.life <= 0 or stage >= MAX_ROUNDS:
				state = BattleState.FINISHED
			else:
				stage += 1
				state = BattleState.STAGE_START
		BattleState.FINISHED:
			emit_signal("battle_finished", {
				"player_life": player.life,
				"enemy_life": enemy.life,
				"stages": stage
			})


func _begin_trigger(p: Player) -> bool:
	var arcana = p.deck.major_arcana
	var total_triggers := p.triggers
	if trigger_index >= total_triggers:
		if arcana and arcana.params.get("repeat_first_trigger", 0) > 0:
			arcana.params.repeat_first_trigger -= 1
			trigger_index = 0
		else:
			return true # finished triggers for this player
	emit_signal("trigger_started", stage, trigger_index)
	resolving_player = p
	resolving_arcana = arcana
	resolving_context = {}
	card_index = 0
	if arcana:
		arcana.before_trigger(p, trigger_index, resolving_context)
	state = BattleState.TRIGGER_CARD
	return false


func _run_trigger_card():
	var cards := resolving_player.deck.cards
	# Finished all cards in this trigger
	if card_index >= cards.size():
		if resolving_arcana:
			resolving_arcana.after_trigger(
				resolving_player,
				trigger_index,
				resolving_context
			)
		emit_signal("trigger_finished", stage, trigger_index)
		emit_signal(
			"battle_log",
			"%s Trigger %d -> power %d"
			% [resolving_player.name, trigger_index, resolving_player.power]
		)
		trigger_index += 1
		# Decide next state
		if resolving_player == player:
			state = BattleState.PLAYER_TRIGGER
		else:
			state = BattleState.ENEMY_TRIGGER
		return
	# Resolve exactly ONE card
	var card := cards[card_index]
	emit_signal("card_resolving", stage, trigger_index, resolving_player, card)
	card.on_trigger(
		resolving_player,
		trigger_index,
		stage,
		resolving_context,
		combat_log
	)
	card_index += 1


func _run_resolution():
	var player_power := player.power
	var enemy_power := enemy.power
	if player.deck.major_arcana:
		player_power = player.deck.major_arcana.modify_power(player, player_power)
	if enemy.deck.major_arcana:
		enemy_power = enemy.deck.major_arcana.modify_power(enemy, enemy_power)
	player.life -= enemy_power
	enemy.life -= player_power
	emit_signal("battle_log", "Resolution: Player %d / Enemy %d" % [player_power, enemy_power])
	emit_signal("damage_resolved", player_power, enemy_power, player.life, enemy.life)


func _cleanup(player: Player):
	player.power = 0
	if player.triggers > 5:
		player.triggers -= 1
