extends CharacterBody2D
class_name Beaker
@onready var non_polar_l := $Glass/NonPolar
@onready var polar_l := $Glass/Polar
@onready var salt_l := $Glass/Salt
@onready var mixture_l := $Glass/Mixture
@onready var glass := $Glass
@onready var beaker_area := $BeakerArea

@export var full_y := 0.0
@export var empty_y := 64.0
@export var full_x := 0.0
@export var empty_x := -53.0
@export var initial_volume := 0.0
@export var max_volume := 100.0
@export var push_force := 80.0
@export var initial_volumes :Array[float] = [0.0, 0.0, 0.0, 0.0]

@export var gravity := 9.81
@export var drag_speed := 20.0
var mouse_in := false
var dragging := false
var pouring := false
var target_beaker : Beaker = null
var volume := 0.0 : set = set_volume
var mouse_offset := Vector2.ZERO
var all_solution : Array[Solution]
# Called when the node enters the scene tree for the first time.
func set_volume(value: float):
	volume = clamp(value, 0, max_volume)
func _ready() -> void:
	var count := 0
	for i in get_children():
		if i is Solution:
			i.volume = initial_volumes[count]
			all_solution.append(i)
			volume += i.volume
			count += 1
	print(all_solution)
	
	draw_volume()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pouring:
		change_volume(-0.1, true)
		if target_beaker and volume != 0:
			for i in range(all_solution.size() - 1, -1, -1):
				if all_solution[i].volume > 0:
					target_beaker.change_volume(0.1, false, all_solution[i].conc, all_solution[i].solvent)
					#print(name, "pouring into", target_beaker.name)
					break
		#await get_tree().create_timer(0.1).timeout
	#liquid.position.y -= 0.1
	#liquid.position.y = clamp(liquid.position.y, 0, 64)
	#await get_tree().create_timer(0.1).timeout
	
func _physics_process(delta: float) -> void:
	if dragging:
		var target_pos := get_global_mouse_position() + mouse_offset
		var target_direction := target_pos - position
		velocity = target_direction * drag_speed
		#print(volume)
		
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity = Vector2.ZERO
			for i in beaker_area.get_overlapping_bodies():
				if i is Ingredient:
					i.external_velocity = Vector2.ZERO
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
		if event.is_action("r_click"):
			if event.is_pressed() and mouse_in:
				pouring = true
				rotate(-PI/2)
				draw_volume(true)
			elif pouring:
				rotate(PI/2)
				pouring = false
				draw_volume()
	
			
func draw_volume(hori := false) -> void:
	var total_vol := 0.0
	for i in all_solution:
		print(i.name,  i.volume)
		total_vol += i.volume
		total_vol = clamp(total_vol, 0, max_volume)
		var ratio := total_vol/max_volume
		var liquid := non_polar_l
		if i.is_polar:
			liquid = polar_l
		if i.is_mixture:
			liquid = mixture_l
		if i.is_salt:
			liquid = salt_l
			
		if hori:
			liquid.position.y = full_y
			liquid.position.x = lerp(empty_x, full_x, ratio)
		else:
			liquid.position.x = full_x
			liquid.position.y = lerp(empty_y, full_y, ratio)

func change_volume(value : float, hori:=false, concentration:Dictionary = {}, solvent:="") -> void:
	if value<0:
		for i in range(all_solution.size() - 1, -1, -1):
			if all_solution[i].volume > 0:
				all_solution[i].decrease_volume(-value)
				break
	else:
		for i in all_solution:
			if i.solvent == solvent:
				i.combine(value, concentration)
	for i in all_solution:
		if i.solvent != "Mixture" and i.volume > 0:
			all_solution[0].separate(i)
	volume += value
	draw_volume(hori)

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
