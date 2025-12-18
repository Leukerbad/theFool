extends Node
class_name BattleTest

@onready var battle_engine := BattleEngineNew.new()

func _ready() -> void:
	print("=== BATTLE TEST START ===")

	# Load data
	CardManager.load_cards("res://Data/cards.json")
	MajorArcanaManager.load_arcana("res://Data/major_arcana.json")

	var fool := MajorArcanaManager.create_arcana("fool")
	var hermit := MajorArcanaManager.create_arcana("hermit")

	# Create player
	var player := _create_test_player(
		"Player",
		["death", "fuel_sigil", "mirror_orb", "chariot", "grave_anchor"]
	)
	player.deck.major_arcana = fool

	# Create enemy
	var enemy := _create_test_player(
		"Enemy",
		["chariot", "fuel_sigil", "fuel_sigil", "mirror_orb", "grave_anchor"]
	)
	enemy.deck.major_arcana = hermit

	# Connect signals
	battle_engine.battle_log.connect(_on_battle_log)
	battle_engine.battle_finished.connect(_on_battle_finished)

	# Start battle
	battle_engine.start(player, enemy)

	# Drive battle manually (test mode)
	while battle_engine.state != BattleEngineNew.BattleState.FINISHED:
		battle_engine.advance()

	print("=== BATTLE TEST END ===")

	
	
static func _create_test_player(player_name: String, card_ids: Array[String]) -> Player:
	CardManager.load_cards("res://Data/cards.json")
	MajorArcanaManager.load_arcana("res://Data/major_arcana.json")
	var player := Player.new()
	player.name = player_name

	var deck := Deck.new()
	deck.owner = player_name

	var positions := ["significator", "past", "present", "future", "outcome"]

	for i in range(card_ids.size()):
		var card := CardManager.create_card(card_ids[i])
		card.position = positions[i]
		deck.cards.append(card)

	player.deck = deck
	return player


func _on_battle_log(message: String) -> void:
	print(message)


func _on_battle_finished(result: Dictionary) -> void:
	print("\n--- RESULT ---")
	print("Player life:", result["player_life"])
	print("Enemy life:", result["enemy_life"])
	print("Stages:", result["stages"])



func _print_result(result: Dictionary) -> void:
	print("\n--- COMBAT LOG ---")

	for entry in result["combat_log"]:
		if entry.trigger_index >= 0:
			print(
				"Stage %d | Trigger %d | %s | %s (%s) -> %s %d"
				% [
					entry.stage,
					entry.trigger_index,
					entry.actor_name,
					entry.card_id,
					entry.position,
					entry.effect,
					entry.value
				]
			)
		else:
			print(
				"Stage %d | %s -> %s %d"
				% [
					entry.stage,
					entry.actor_name,
					entry.effect,
					entry.value
				]
			)

	print("\n--- RESULT ---")
	print("Player life:", result["player_life"])
	print("Enemy life:", result["enemy_life"])
	print("Stages:", result["stages"])
