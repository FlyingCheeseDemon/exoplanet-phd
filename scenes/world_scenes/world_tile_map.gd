extends TileMapLayer

signal cell_clicked

const world_atlas_id = 0
const water_tiles:Array[Vector2] = [Vector2(0,0)]
const soil_tiles:Array[Vector2] = [Vector2(1,0),Vector2(2,0)]

@export var perlin_noise:FastNoiseLite
@export var water_threshold:float = -0.2
@export var mountain_threshold:float = 0.2
@export var range_factor:float = 0.01
@export var render_range:int = 50

const HEX_DIRECTIONS:Array[Vector2i] = [Vector2i(0,1),Vector2i(0,-1),Vector2i(1,0),Vector2i(-1,0),Vector2i(1,-1),Vector2i(-1,1)]

func _unhandled_input(event:InputEvent) -> void:
	
	if event is InputEventMouseButton:
		if event.is_pressed():
			var global_clicked:Vector2 = get_local_mouse_position()
			var pos_clicked:Vector2i = local_to_map(to_local(global_clicked))
			cell_clicked.emit(event,pos_clicked)

func _ready() -> void:
	perlin_noise.seed = randi()
	# randomize map based on perlin noise
	for i in range(-render_range, render_range):
		for j in range(-render_range,render_range):
			var coord := Vector2i(i,j)
			var perlin_value = perlin_noise.get_noise_2d(i+j*0.5,j*sqrt(3)/2)
			var tile_inx:int = 1
			var distance:float = hex_len(Vector2i(i,j))
			if perlin_value < water_threshold*exp(-(distance/range_factor)**2):
				tile_inx = 0
			elif perlin_value > mountain_threshold*exp(-(distance/range_factor)**2):
				tile_inx = 2
			
			var tile_coordinate = tile_set.get_source(world_atlas_id).get_tile_id(tile_inx)
			set_cell(coord,world_atlas_id,tile_coordinate)

func plot_course(start:Vector2i,end:Vector2i) -> Array[Vector2i]:
	# floodfill
	if start == end:
		return []
	
	var frontier_queue:Array[Vector2i] = [end]
	var next_tile_to_goal:Dictionary = {}
	
	while not start in next_tile_to_goal.keys():
		if len(frontier_queue) == 0: # target unreachable
			return []
		var current_position = frontier_queue.pop_front()
		for direction in HEX_DIRECTIONS:
			var next_position:Vector2i = current_position + direction
			if get_cell_tile_data(next_position).terrain_set != 1:
				continue # impassable
			if next_position in next_tile_to_goal.keys():
				continue # already visited
			frontier_queue.append(next_position)
			next_tile_to_goal[next_position] = current_position
		
	var course:Array[Vector2i] = [start]
		
	while course[-1] != end:
		course.append(next_tile_to_goal[course[-1]])
	
	course.pop_front() # worker is already at this position and doesn't need to move there
	return course

func hex_len(vector:Vector2i) -> int:
	if sign(vector[0]) == sign(vector[1]):
		return abs(vector[0] + vector[1])
	else:
		var direction_k:int = min(abs(vector[0]),abs(vector[1]))
		var remainder:int = abs(abs(vector[0])-abs(vector[1]))
		return direction_k + remainder
	
