extends HBoxContainer

var CardUIScene = preload("res://Scenes/Deck/Card.tscn")

var card_ui_nodes: Array = []

func populate(cards: Array):
	for child in get_children():
		child.queue_free()
	card_ui_nodes.clear()
	for card in cards:
		var card_ui := CardUIScene.instantiate()
		add_child(card_ui)
		card_ui.bind(card)
		card_ui_nodes.append(card_ui)


func update_all(cards: Array) -> void:
	# Safety check
	if cards.size() != card_ui_nodes.size():
		push_warning("Deck UI mismatch: cards=%d ui=%d" % [cards.size(), card_ui_nodes.size()])
	
	var count = min(cards.size(), card_ui_nodes.size())

	for i in range(count):
		card_ui_nodes[i].bind(cards[i])


func highlight_card(card: Card):
	for ui in card_ui_nodes:
		if ui.card != null and ui.card.id == card.id:
			ui.highlight_active()


func clear_all_highlights():
	for ui in card_ui_nodes:
		ui.clear_highlight()
