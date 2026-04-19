extends StaticBody2D
class_name SolventBarrel
const OPERATIONS := preload("res://Res/operations.tres")
@export_enum("Salt", "Polar", "Non-polar", "Acid") var solvent : String
@export var UI_communicator : UICommunicator
@export var item_name : String
@export var desc : String
var conc : Dictionary[String, Dictionary]
var beaker: Beaker
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	conc = OPERATIONS.get_empty_dict()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if beaker:
		if solvent != "Acid":
			beaker.change_volume(0.1, conc, solvent)
		else:
			beaker.acidify()
			beaker.change_volume(0.1, conc, "Salt")



func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Beaker and body is not BottleOfPotion and body is not BeakerCup:
		beaker = body
		$GPUParticles2D.emitting = true


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Beaker and body is not BottleOfPotion and body is not BeakerCup:
		beaker = null
		$GPUParticles2D.emitting = false


func _on_area_2d_2_mouse_entered() -> void:
	if UI_communicator:
		UI_communicator.display_request.emit(item_name, "", desc)
	

func _on_area_2d_2_mouse_exited() -> void:
	if UI_communicator:
		UI_communicator.stop_display.emit()
