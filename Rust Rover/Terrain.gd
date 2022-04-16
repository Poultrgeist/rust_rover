extends TileMap

class Tile:
	var _tilemap_pos : Vector2
	var _type : int
	var _structure : Structure = null
	var _powered : bool = false
	
	func _init(pos : Vector2, type : int):
		_tilemap_pos = pos
		_type = type
	
	func set_type(type : int):
		_type = type
	
	func get_type() -> int:
		return _type
	
	func build_structure(structure):
		_structure = structure
	
	func get_structure():
		return _structure
	
	func get_structure_type() -> int:
		# returns struture type or -1 if no structure
		if _structure != null:
			return _structure.structure_type
		else:
			return -1
	
	func get_tilemap_pos() -> Vector2:
		return _tilemap_pos
	
	func is_powered() -> bool:
		return _powered
