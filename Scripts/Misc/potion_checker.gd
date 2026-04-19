extends Node
class_name PotionChecker
@export_enum("Wood", "Fire", "Water", "Earth", "Metal", "Cursed Wood", "Cursed Fire", "Cursed Water", "Cursed Earth", "Cursed Metal")var majors : Array[String]
@export_enum("Physical", "Mental", "Unset") var effect : String
@export var min_strength : int
@export var max_strength : int
@export var reward : int
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func check_potion(potion:Potion) -> int:
	if potion.majors.size() != majors.size():
		return 0
	for i in majors:
		if i not in potion.majors:
			return 1
	if effect == "Physical":
		if not potion.is_physical:
			return 2
	if effect == "Mental":
		if not potion.is_mental:
			return 3
	if effect == "Unset":
		if potion.is_set:
			return 4
	if potion.strength < min_strength:
		return 5	
	if potion.strength > max_strength:
		return 6
	reward = (potion.purity + 0.5) * reward
	return 7
