extends Node2D

@onready var map_1:TileMapLayer = $VisualMap1
@onready var map_2:TileMapLayer = $VisualMap2
@onready var both_maps:Array[TileMapLayer] = [map_1,map_2]

const NEIGHBORS1:Array[Vector2i] = [Vector2i(0,0),Vector2i(-1,1),Vector2i(0,1)]
const NEIGHBORS2:Array[Vector2i] = [Vector2i(1,-1),Vector2i(0,-1),Vector2i(0,0)]
const NEIGHBORS:Array = [NEIGHBORS1,NEIGHBORS2]

func _ready() -> void:
	pass

var next_binary_values_1:Array[Array]
var next_binary_values_2:Array[Array]

func after_world_map_update(world_map:TileMapLayer) -> void:
	var render_range = world_map.render_range - 1
	for i in range(-render_range,render_range):
		for j in range(-render_range,render_range):
			var values:Array[Array] = [[0,0,0],[0,0,0]]
			for map_inx in range(2):
				for k in range(3):
					var global_coordinate:Vector2i = Vector2i(i,j) + NEIGHBORS[map_inx][k]
					values[map_inx][k] = world_map.get_cell_tile_data(global_coordinate).terrain_set
				
				var column:int = 0
				var orientation:int = 0
				match values[map_inx]:
					[0,_,_]:
						match values[map_inx]:
							[_,0,_]:
								match values[map_inx]:
									[_,_,0]:
										column = 0
										orientation = randi_range(0,2)
									[_,_,1]:
										column = 3
										orientation = 0
									[_,_,2]:
										column = 4
										orientation = 0
							[_,1,_]:
								match values[map_inx]:
									[_,_,0]:
										column = 3
										orientation = 2
									[_,_,1]:
										column = 5
										orientation = 1
									[_,_,2]:
										column = 9
										orientation = 0
							[_,2,_]:
								match values[map_inx]:
									[_,_,0]:
										column = 4
										orientation = 2
									[_,_,1]:
										column = 10
										orientation = 1
									[_,_,2]:
										column = 7
										orientation = 1
					[1,_,_]:
						match values[map_inx]:
							[_,0,_]:
								match values[map_inx]:
									[_,_,0]:
										column = 3
										orientation = 1
									[_,_,1]:
										column = 5
										orientation = 2
									[_,_,2]:
										column = 10
										orientation = 2
							[_,1,_]:
								match values[map_inx]:
									[_,_,0]:
										column = 5
										orientation = 0
									[_,_,1]:
										column = 2
										orientation = randi_range(0,2)
									[_,_,2]:
										column = 6
										orientation = 0
							[_,2,_]:
								match values[map_inx]:
									[_,_,0]:
										column = 9
										orientation = 2
									[_,_,1]:
										column = 6
										orientation = 2
									[_,_,2]:
										column = 8
										orientation = 1
					[2,_,_]:
						match values[map_inx]:
							[_,0,_]:
								match values[map_inx]:
									[_,_,0]:
										column = 4
										orientation = 1
									[_,_,1]:
										column = 9
										orientation = 1
									[_,_,2]:
										column = 7
										orientation = 2
							[_,1,_]:
								match values[map_inx]:
									[_,_,0]:
										column = 10
										orientation = 0
									[_,_,1]:
										column = 6
										orientation = 1
									[_,_,2]:
										column = 8
										orientation = 2
							[_,2,_]:
								match values[map_inx]:
									[_,_,0]:
										column = 7
										orientation = 0
									[_,_,1]:
										column = 8
										orientation = 0
									[_,_,2]:
										column = 1
										orientation = randi_range(0,2)

				both_maps[map_inx].set_cell(Vector2i(i,j),orientation,Vector2i(column,0))
			
