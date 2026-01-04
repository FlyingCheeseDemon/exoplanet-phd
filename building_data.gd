extends Resource
class_name BuildingData


@export var name:String
@export var texture:Texture
@export var occupancy:Array[Vector2i]
@export var texture_offset:Vector2

enum BUILDING_TYPE {STANDARD,SCIENCE}
@export var type:BUILDING_TYPE
