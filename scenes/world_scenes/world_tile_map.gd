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
			var distance:float = sqrt(i*i+j*j)
			if perlin_value < water_threshold*exp(-(distance/range_factor)**2):
				tile_inx = 0
			elif perlin_value > mountain_threshold*exp(-(distance/range_factor)**2):
				tile_inx = 2
			
			var tile_coordinate = tile_set.get_source(world_atlas_id).get_tile_id(tile_inx)
			set_cell(coord,world_atlas_id,tile_coordinate)
	
