extends Resource

class_name WorldObjectData

const RESTRICTION_WATER:int = 1
const RESTRICTION_LAND:int = 2
const RESTRICTION_MOUNTAIN:int = 4

@export var name:String
@export_multiline var info:String
@export var texture:Texture
@export var occupancy:Array[Vector2i] = [Vector2i(0,0)]
@export_flags("Water", "Land", "Mountain") var build_restriction
@export var texture_offset:Vector2

@export var actions:Array[ObjectAction]
