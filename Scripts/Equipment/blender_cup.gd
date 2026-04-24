extends Beaker
class_name BeakerCup
signal volume_updated
signal moving
signal back
var active := true
var initial_pos : Vector2 
var left := false
@onready var twig : AnimatedSprite2D = $Twig
@onready var mixture := $Mixture

func _ready() -> void:
	super()
	item_name = "Blender"
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
			if initial_pos.distance_to(position) <= 0.5 and left:
				back.emit()
				left = false
		for i in beaker_area.get_overlapping_bodies():
			if i is Ingredient:
				i.external_velocity = velocity
		move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action("l_click"):
			if event.is_pressed() and mouse_in:
				print("clicked")
				dragging = true
				left = true
				moving.emit()
				mouse_offset = position - get_global_mouse_position()
				for i in beaker_area.get_overlapping_bodies():
					if i is Ingredient and i.mouse_in:
						dragging = false
				
			else:
				dragging = false
		if event.is_action("r_click") and active:
			if event.is_pressed() and mouse_in:
				pouring = true
				draw_volume()
			elif pouring:
				volume_updated.emit()
				pouring = false
				particle.emitting = false
				draw_volume()

	
	

func purge() -> void:
	print("purged")
	
	for i in all_solution:
		i.decrease_volume(i.volume)
	volume = 0
	volume_updated.emit()
	draw_volume()



func _on_beaker_area_pourable(beaker: Beaker) -> void:

	target_beaker = beaker




func _on_click_area_mouse_entered() -> void:
	print("mousin")
	mouse_in = true
	if UI_communicator:
		var n := item_name 
		if n == "":
			n = generate_default_name()
		UI_communicator.emit_signal("display_request", self, "Blender", generate_comp_text(), generate_desc())



func _on_click_area_mouse_exited() -> void:
	print("mouseout")
	mouse_in = false
	if UI_communicator:
		UI_communicator.emit_signal("stop_display", self)
