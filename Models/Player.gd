class_name Player

var name: String = ""
var life: int = 20
var power: int = 0
var triggers: int = 1
var deck: Deck

func reset_state() -> void:
	life = 20
	power = 0
	triggers = 1
