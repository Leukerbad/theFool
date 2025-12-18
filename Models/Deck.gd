class_name Deck

var owner: String = ""
var major_arcana_id: String = ""
var major_arcana: MajorArcana
var cards: Array[Card] = []

func to_json() -> String:
	var data := {
		"owner": owner,
		"major_arcana_id": major_arcana_id,
		"cards": cards.map(func(c: Card) -> String: return c.id)
	}
	return JSON.stringify(data)

func from_json(json_data: String) -> void:
	var json = JSON.new()
	var result := json.parse(json_data)
	if result != OK:
		push_error("Failed to parse deck json")
		return
	var data = json.data
	owner = data.get("owner", "")
	major_arcana_id = data.get("major_arcana", "")
	cards.clear()
	for card_id in data.get("cards", []):
		var card := CardManager.create_card(card_id)
		if card:
			cards.append(card)
