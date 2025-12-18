class_name MajorArcanaManager

static var definitions: Dictionary = {}

static func load_arcana(path: String) -> void:
	var file := FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	var result = json.parse(file.get_as_text())
	if result != OK:
		push_error("Failed to parse major arcana json")
		return
	for entry in json.data:
		definitions[entry.id] = entry

static func create_arcana(id: String) -> MajorArcana:
	var def = definitions[id]
	var arcana = MajorArcana.new()
	arcana.id = def.id
	arcana.name_key = def.name_key
	arcana.description_key = def.desc_key
	arcana.params = def.get("params", {})
	return arcana
