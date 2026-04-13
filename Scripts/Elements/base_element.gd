extends Node
class_name BaseElement

@export_enum("Wood", "Fire", "Water", "Earth", "Metal") var type: String
@export_enum("Polar", "Non-polar", "Salt", "Elemental") var state: String
@export var moles := 1.0
@export var is_polar := false
@export var is_non_polar := false
@export var is_metal := false
@export var is_salt := false
@export var distill_temp := 10.0

var full_name : String

func _ready() -> void:
	if is_polar or is_non_polar or is_metal:
		full_name = state +" "+type
	else:
		full_name = type + " " + state
