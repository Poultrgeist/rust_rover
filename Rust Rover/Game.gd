extends Node2D

var metal : float
var water : float
var terrain_tiles : Array
var selected_structure : Structure
export (float, 0.0, 1.0) var game_tick : float = 0.1
var _tick_timer : float = 0.0
export (int) var initial_metal : int

var earth_eaters : Array
var ice_drills: Array

onready var terrain : TileMap = $Terrain
onready var structures : TileMap = $Structures # PLS ONLY FOR ASETHETICS
onready var rover_map : TileMap = $Planet/Navigation2D/Map
onready var metal_label = $UI/Counters/MetalLabel
onready var water_label = $UI/Counters/WaterLabel

func _ready():
	_init_tilemap()
	
	#initialize counters
	metal = initial_metal
	_update_counters()
	
	# initialize buttons
	for button in $UI/Buttons.get_children():
		button.connect("pressed", self, "_on_structure_button_pressed", [button.structure])
	

func _on_structure_button_pressed(structure):
	# sets selected stucture
	selected_structure = structure #FIND SOMEWAY TO DESELECT PLS

func _init_tilemap():
	# create 2d array with size of tilemap
	var used : Rect2 = terrain.get_used_rect()
	var grid_width = used.size.x
	var grid_height = used.size.y
	for x in range(grid_width): 
		terrain_tiles.append([])
		for y in range(grid_height):
			terrain_tiles[x].append(0)
	
	# initialize the tile object for each tile in tilemap
	var tiles_pos : Array = terrain.get_used_cells()
	for pos in tiles_pos:
		terrain_tiles[pos.x - 1][pos.y - 1] = terrain.Tile.new(pos, terrain.get_cellv(pos))

func _input(event):
	# left button click
	if (event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_LEFT):
		var mouse_pos = terrain.world_to_map(get_global_mouse_position())
		if terrain.get_used_cells().has(mouse_pos):
			if selected_structure != null:
				if selected_structure.placement_check(terrain_tiles[mouse_pos.x - 1][mouse_pos.y - 1], terrain) && _buy(selected_structure):
					structures.set_cellv(mouse_pos, selected_structure.structure_type)
					terrain_tiles[mouse_pos.x - 1][mouse_pos.y - 1].build_structure(selected_structure)
					_update_tiles()
	elif (event is InputEventMouseButton && event.is_pressed() && event.button_index == BUTTON_RIGHT):
		var mouse_pos = terrain.world_to_map(get_global_mouse_position())
		if rover_map.get_used_cells().has(mouse_pos):
			pass
			#set target location here

func _process(delta):
	_tick_timer -= delta
	if _tick_timer <= 0: #execute this code every tick
#		for earth_eater in earth_eaters:
#			metal += 0.5 #FIDN SOME WAY TO CHANGE THIS FROM EDITOR?!
#		for ice_drill in ice_drills:
#			water += 0.1 #FIDN SOME WAY TO CHANGE THIS FROM EDITOR?!
		metal += 0.5 * earth_eaters.size()
		water += 0.1 * ice_drills.size()
		_update_counters()
		
		#resets timer
		_tick_timer = game_tick 

func _update_tiles():
	#first pass clears all data
	for tile_pos in terrain.get_used_cells():
		var tile = terrain_tiles[tile_pos.x - 1][tile_pos.y - 1]
		tile._powered = false
	earth_eaters.clear() #i really hope thisnot expensive
	ice_drills.clear()
	#second pass updates data
	for tile_pos in terrain.get_used_cells():
		var tile = terrain_tiles[tile_pos.x - 1][tile_pos.y - 1]
		match tile.get_structure_type():
			0: # power generators
				for adj_pos in _adjacent(tile_pos):
					terrain_tiles[adj_pos.x - 1][adj_pos.y - 1]._powered = true
			3: # ice drills
				ice_drills.append(tile_pos)
			6: # eath eaters
				earth_eaters.append(tile_pos)

func _adjacent(pos : Vector2) -> Array: #NOTE: CHANGE SO MIDDLE TILE IS NOT POWERED
	var adjacent_positions = []
	for x in range(pos.x - 1, pos.x + 2):
		adjacent_positions.append(Vector2(x, pos.y))
	adjacent_positions.append(Vector2(pos.x, pos.y + 1))
	adjacent_positions.append(Vector2(pos.x, pos.y - 1))
	return adjacent_positions

func _square(pos : Vector2) -> Array:
	var adjacent_positions = []
	for x in range(pos.x - 1, pos.x + 2):
		for y in range(pos.y - 1, pos.y + 2):
			adjacent_positions.append(Vector2(x, y))
	return adjacent_positions

func _update_counters():
	metal_label.text = "Metal: " + str(floor(metal))
	water_label.text = "Water: " + str(floor(water))

func _buy(structure : Structure) -> bool:
	if structure.cost < metal:
		metal -= structure.cost
		return true
	else:
		return false
