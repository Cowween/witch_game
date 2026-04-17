extends Beaker
class_name BottleOfPotion

var active := true
var in_distillator := false
var distillator_pos := Vector2.ZERO
var potion : Potion
var is_complete := false
@onready var liquid := $Glass/Liquid

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	liquid.position.y = empty_y
	#fill_up()


func _physics_process(delta: float) -> void:

	if active:
		if dragging:
			var target_pos := get_global_mouse_position() + mouse_offset
			var target_direction := target_pos - position
			velocity = target_direction * drag_speed
		elif in_distillator:
			var target_direction := distillator_pos - position
			velocity = target_direction * drag_speed
		else:
			if not is_on_floor():
				velocity.y += gravity * delta
			else:
				velocity = Vector2.ZERO
				velocity.x = move_toward(velocity.x, 0, 500 * delta)
		move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action("l_click"):
			if event.is_pressed() and mouse_in:
				dragging = true
				mouse_offset = position - get_global_mouse_position()
				
			else:
				dragging = false

func fill_up() -> void:
	var tween = create_tween()
	tween.tween_method(
		func(progress):
			# Sample curve to get interpolated value
			var curve_val = fill_curve.sample(progress)
			liquid.position.y = lerp(empty_y, full_y, curve_val)
	, 0.0, 1.0, 10.0
		
	)

func _on_click_area_mouse_entered() -> void:
	mouse_in = true
	if UI_communicator:
		var n := "Flask"
		var c := ""
		var d := ""
		if potion:
			n = potion.generic_name()
			c = potion.generate_comp_text()
			d = potion.generate_desc()
		UI_communicator.emit_signal("display_request", n, c, d)



func _on_click_area_mouse_exited() -> void:
	mouse_in = false
	if UI_communicator:
		UI_communicator.emit_signal("stop_display")
