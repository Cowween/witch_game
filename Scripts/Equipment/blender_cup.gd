extends Beaker

signal volume_updated
var active := true
var initial_pos : Vector2
@onready var mixture := $Mixture

func _ready() -> void:
	super()
	print(all_solution)
	
func _process(delta: float) -> void:
	super(delta)
	
func _physics_process(delta: float) -> void:
	if active:
		if dragging:
			var target_pos := get_global_mouse_position() + mouse_offset
			var target_direction := target_pos - position
			velocity = target_direction * drag_speed
			
		else:
			var target_direction := initial_pos - position
			velocity = target_direction * drag_speed
		for i in beaker_area.get_overlapping_bodies():
			if i is Ingredient:
				i.external_velocity = velocity
		move_and_slide()
	
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
				draw_volume(true)
			elif pouring:
				volume_updated.emit()
				rotate(PI/2)
				pouring = false
				draw_volume()

func _on_area_2d_mouse_entered() -> void:

	mouse_in = true


func _on_area_2d_mouse_exited() -> void:
	mouse_in = false


func _on_pour_receptor_area_entered(area: Area2D) -> void:
	area.emit_signal("pourable", self)


func _on_beaker_area_pourable(beaker: Beaker) -> void:
	target_beaker = beaker


func _on_pour_receptor_area_exited(area: Area2D) -> void:
	area.emit_signal("pourable", null)
