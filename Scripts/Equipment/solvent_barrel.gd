extends StaticBody2D
class_name SolventBarrel
const OPERATIONS := preload("res://Res/operations.tres")
@export_enum("Salt", "Polar", "Non-polar", "Acid") var solvent : String
var conc : Dictionary[String, Dictionary]
var beaker: Beaker
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	conc = OPERATIONS.get_empty_dict()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if beaker:
		if solvent != "Acid":
			beaker.change_volume(0.1, false, conc, solvent)
		else:
			beaker.acidify()
			beaker.change_volume(0.1, false, conc, "Salt")



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Beaker:
		beaker = body


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Beaker:
		beaker = null
