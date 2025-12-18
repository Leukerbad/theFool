extends Control

@onready var name_label = $NameLabel
@onready var position_label = $PositionLabel
@onready var power_label = $PowerLabel
@onready var highlight := $Highlight

var card: Card

func bind(c: Card) -> void:
	card = c
	update_ui()


func update_ui() -> void:
	if card == null:
		return
	name_label.text = card.id
	power_label.text = str(card.power)
	position_label.text = card.position


func highlight_active():
	highlight.modulate.a = 0.8


func clear_highlight():
	highlight.modulate.a = 0.0
