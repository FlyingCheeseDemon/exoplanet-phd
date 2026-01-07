extends WorldObjectData
class_name ResourcePileData
const RESOURCE_ENUM = preload("res://assets/resources/resources.gd")

@export var contained_resource:RESOURCE_ENUM.RESOURCE_TYPES
@export var contained_amount:int

enum COLORATION_TAG {NONE,WATER,GROUND}
@export var color_tag:COLORATION_TAG
