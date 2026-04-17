extends Beaker
class_name RoundBottomedFlask

var active := true
var in_distillator := false
var distillator_pos := Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)

func _physics_process(delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action("l_click"):
			if event.is_pressed() and mouse_in:
				dragging = true
				mouse_offset = position - get_global_mouse_position()
				for i in beaker_area.get_overlapping_bodies():
					if i is Ingredient and i.mouse_in:
						dragging = false
				
			else:
				dragging = false
		if event.is_action("r_click") and active:
			if event.is_pressed() and mouse_in:
				pouring = true
				rotate(-PI/2)
				draw_volume()
			elif pouring:
				rotate(PI/2)
				pouring = false
				draw_volume()

	
	





func _on_beaker_area_pourable(beaker: Beaker) -> void:

	target_beaker = beaker


func _on_pour_receptor_area_exited(area: Area2D) -> void:
	area.emit_signal("pourable", null)


func _on_click_area_mouse_entered() -> void:
	mouse_in = true
	tally_effects()
	if UI_communicator:
		var n := item_name 
		if n == "":
			n = generate_default_name()
		UI_communicator.emit_signal("display_request", n, generate_comp_text(), generate_desc())



func _on_click_area_mouse_exited() -> void:
	mouse_in = false
	if UI_communicator:
		UI_communicator.emit_signal("stop_display")
