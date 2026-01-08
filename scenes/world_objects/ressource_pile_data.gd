extends WorldObjectData
class_name ResourcePileData

@export var contained_resource:MyEnums.RESOURCE_TYPES
@export var contained_amount:int

enum COLORATION_TAG {NONE,WATER,GROUND}
@export var color_tag:COLORATION_TAG
