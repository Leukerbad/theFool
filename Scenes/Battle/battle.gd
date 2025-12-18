extends Control

@onready var player_deck_ui = $VBoxContainer/PlayerDeck
@onready var enemy_deck_ui = $VBoxContainer/EnemyDeck
@onready var stage_label = $VBoxContainer/StageLabel
@onready var combat_log = $VBoxContainer/CombatLog
@onready var timer := $StepTimer

var battle_engine: BattleEngineNew
var player: Player
var enemy: Player


func _ready():
	# Create players
	player = BattleTest._create_test_player(
		"Player",
		["death", "fuel_sigil", "mirror_orb", "chariot", "grave_anchor"]
	)
	player.deck.major_arcana = MajorArcanaManager.create_arcana("fool")

	enemy = BattleTest._create_test_player(
		"Enemy",
		["chariot", "fuel_sigil", "fuel_sigil", "mirror_orb", "grave_anchor"]
	)
	enemy.deck.major_arcana = MajorArcanaManager.create_arcana("hermit")

	# Populate UI
	player_deck_ui.populate(player.deck.cards)
	enemy_deck_ui.populate(enemy.deck.cards)

	# Create engine
	battle_engine = BattleEngineNew.new()
	battle_engine.trigger_started.connect(_on_trigger_started)
	battle_engine.trigger_finished.connect(_on_trigger_finished)
	battle_engine.battle_log.connect(_on_battle_log)
	battle_engine.battle_finished.connect(_on_battle_finished)
	battle_engine.card_resolving.connect(_on_card_resolving)
	# Start battle
	timer.timeout.connect(_on_step_timeout)

	battle_engine.start(player, enemy)
	timer.start(0.5) # seconds between steps


func _on_step_timeout():
	if battle_engine.state != BattleEngineNew.BattleState.FINISHED:
		battle_engine.advance()


func _on_trigger_started(stage: int, trigger_index: int):
	stage_label.text = "Stage %d | Trigger %d" % [stage, trigger_index]


func _on_trigger_finished(stage: int, trigger_index: int):
	# Power is read directly from actors
	player_deck_ui.update_all(player.deck.cards)
	enemy_deck_ui.update_all(enemy.deck.cards)


func _on_battle_log(message: String):
	combat_log.text += message + "\n"


func _on_battle_finished(result: Dictionary):
	combat_log.text += "\n=== BATTLE ENDED ===\n"
	combat_log.text += "Player life: %d\n" % result.player_life
	combat_log.text += "Enemy life: %d\n" % result.enemy_life


func _on_card_resolving(stage, trigger_index, actor, card):
	player_deck_ui.clear_all_highlights()
	enemy_deck_ui.clear_all_highlights()
	if actor.name == "Player":
		player_deck_ui.highlight_card(card)
	else:
		enemy_deck_ui.highlight_card(card)
