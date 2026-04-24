extends Beaker
class_name RoundBottomedFlask

var active := true
var open := true
var in_distillator := false
var distillator_pos := Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if open:
		super(delta)

func _physics_process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	pass
	







func _on_pour_receptor_area_exited(area: Area2D) -> void:
	area.emit_signal("pourable", null)

	


func _on_beaker_area_mouse_entered() -> void:
	mouse_in = true
	tally_effects()
	if UI_communicator:
		print("here")
		UI_communicator.emit_signal("display_request", self, "Distillation Flask", generate_comp_text(), generate_desc())


func _on_beaker_area_mouse_exited() -> void:
	mouse_in = false
	if UI_communicator:
		UI_communicator.emit_signal("stop_display", self)
