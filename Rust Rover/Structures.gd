extends Resource
class_name Structure

export (int) var structure_type
export (int) var cost : int
export (bool) var needs_power
export (Array) var valid_types = []

func placement_check(tile, tilemap : TileMap) -> bool:
	if tile_check(tile.get_tilemap_pos(), tilemap):
		if needs_power:
			if power_check(tile):
				return true
			else:
				return false
		else:
			return true
	else:
		return false

func tile_check(tile_pos : Vector2, tilemap : TileMap) -> bool:
	for tile_type in valid_types:
		if tilemap.get_cellv(tile_pos) == tile_type:
			return true
	return false

func power_check(tile) -> bool:
	if tile.is_powered():
		return true
	return false
