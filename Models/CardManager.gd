class_name CardManager

static var card_definitions: Dictionary = {}


static func load_cards(json_file_path: String) -> void:
	var file := FileAccess.open(json_file_path, FileAccess.READ)
	if not file:
		push_error("Cards file not found")
		return
	var json = JSON.new()
	var result := json.parse(file.get_as_text())
	if result != OK:
		push_error("Failed to parse cards json")
		return
	for card_def in json.data:
		card_definitions[card_def["id"]] = card_def


static func create_card(card_id: String) -> Card:
	var card_def = card_definitions.get(card_id)
	if not card_def:
		push_error("Card ID not found: %s" % card_id)
		return null
	var card := Card.new()
	card.id = card_def.id
	card.name_key = card_def.name_key
	card.description_key = card_def.desc_key
	card.type = card_def.type
	card.position_effects = card_def.get("position_effects", {})
	return card
