class_name CombatLog

var entries: Array[CombatLogEntry] = []

func add_entry(
	stage: int,
	trigger_index: int,
	actor_name: String,
	card_id: String,
	position: String,
	effect: String,
	value: int
) -> void:
	var entry := CombatLogEntry.new()
	entry.stage = stage
	entry.trigger_index = trigger_index
	entry.actor_name = actor_name
	entry.card_id = card_id
	entry.position = position
	entry.effect = effect
	entry.value = value
	entries.append(entry)
