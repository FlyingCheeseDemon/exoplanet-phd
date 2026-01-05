extends WorldObjectData
class_name ResourcePileData

enum CONTAINED_RESOURCE {SOIL,ROCK}
@export var contained_resource:CONTAINED_RESOURCE
@export var contained_amount:int

enum COLORATION_TAG {NONE,WATER,GROUND}
@export var color_tag:COLORATION_TAG
