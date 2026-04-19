extends CharacterBody2D
class_name Beaker
@onready var non_polar_l := $Glass/NonPolar
@onready var polar_l := $Glass/Polar
@onready var salt_l := $Glass/Salt
@onready var mixture_l := $Glass/Mixture
@onready var elixir_l := $Glass/Elixir
@onready var glass := $Glass
@onready var beaker_area := $BeakerArea
@onready var pour_receptor := $PourReceptor
@export var particle : GPUParticles2D

@export var fill_curve : Curve
@export var full_y := 0.0
@export var empty_y := 64.0
@export var full_x := 0.0
@export var empty_x := -53.0
@export var initial_volume := 0.0
@export var max_volume := 100.0
@export var push_force := 80.0
@export var initial_volumes :Array[float] = [0.0, 0.0, 0.0, 0.0, 0.0]
@export var UI_communicator : UICommunicator

@export var gravity := 9.81
@export var drag_speed := 20.0
const OPERATIONS := preload("res://Res/operations.tres")
var mouse_in := false
var dragging := false
var pouring := false
var target_beaker : Beaker = null
var target_cauldron : Cauldron = null
var volume := 0.0 : set = set_volume
var mouse_offset := Vector2.ZERO
var all_solution : Array[Solution] #mixture, salt, polar, nonpolar, elixir
var total_amount : Dictionary[String, Dictionary]
var total_comp : Dictionary[String, float]
var item_name := ""
var solute : Array[Ingredient]
# Called when the node enters the scene tree for the first time.
func set_volume(value: float):
	volume = clamp(value, 0, max_volume)
func _ready() -> void:
	var count := 0
	for i in get_children():
		if i is Solution:
			i.volume = initial_volumes[count]
			i.max_volume = max_volume
			all_solution.append(i)
			volume += i.volume
			count += 1
	print(all_solution)
	total_amount = OPERATIONS.get_empty_dict()
	#print(all_solution)
	tally_effects()
	#print(total_amount)
	draw_volume()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pour_receptor:
		for i in pour_receptor.get_overlapping_areas():
			print(i)
			i.emit_signal("pourable", self)
	if pouring:
		change_volume(-0.1)
		if volume != 0:
			particle.emitting = true
		else:
			particle.emitting = false
		if target_beaker and volume != 0:
			
			for i in range(all_solution.size() - 1, -1, -1):
				if all_solution[i].volume > 0:
					if all_solution[i].acidified:
						target_beaker.acidify()
					target_beaker.change_volume(0.1, all_solution[i].conc, all_solution[i].solvent)
					#print(name, "pouring into", target_beaker.name)
					break
		if target_cauldron and volume != 0:
			for i in range(all_solution.size() - 1, -1, -1):
				if all_solution[i].volume > 0:
					target_cauldron.combine(0.1, all_solution[i].conc)
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
		var raw_velocity := target_direction * drag_speed
		velocity = raw_velocity.limit_length(500)
		#print(volume)
		
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity = Vector2.ZERO
			for i in beaker_area.get_overlapping_bodies():
				if i is Ingredient:
					i.external_velocity = Vector2.ZERO
			velocity.x = move_toward(velocity.x, 0, 500 * delta)
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
						print(i.mouse_in)
						dragging = false
				
			else:
				dragging = false
		if event.is_action("r_click"):
			if event.is_pressed() and mouse_in:
				pouring = true
				
				draw_volume()
			elif pouring:
				pouring = false
				particle.emitting = false
				draw_volume()



func tally_effects() -> void:
	total_amount = OPERATIONS.get_empty_dict()
	total_comp = {}
	for solution in all_solution:
		#print(solution.el_composition)
		for element in solution.el_composition:
			
			total_comp[element] = total_comp.get(element, 0) + solution.el_composition[element]
		for outer_key in solution.amounts.keys():
			# Initialize the outer dictionary if it doesn't exist yet

			
			var inner_dict = solution.amounts[outer_key]
			for inner_key in inner_dict.keys():
				# Initialize the float value to 0 if it's the first time we see it
				
				# Add the value to the total
				total_amount[outer_key][inner_key] += inner_dict[inner_key]
	
		
			
func draw_volume(a:Dictionary = {}) -> void:
	#print("Draw vol")
	var total_vol := 0.0
	if pouring:
		glass.rotation = lerpf(-PI/2, 0, volume/max_volume)

	else:
		glass.rotation = 0

	for i in all_solution:
		#print(i.name,  i.volume)
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
		if i.is_elixir:
			liquid = elixir_l
		if fill_curve:
			ratio = fill_curve.sample(ratio)
		print(name, i.name, i.el_composition)
		liquid.modulate = OPERATIONS.generate_color(i.el_composition)
		if not a.is_empty():
			liquid.modulate = OPERATIONS.generate_color(a)
		if pouring:
			var new_pos := Vector2(full_x, lerp(empty_x, full_y, ratio))
			liquid.global_position = to_global(new_pos)
		else:
			var new_pos := Vector2(full_x, lerp(empty_y, full_y, ratio))
			liquid.position = new_pos
			
		if i.volume == 0.0:
			liquid.position.y = 999

func change_volume(value : float, concentration:Dictionary = {}, solvent:="") -> void:
	if max_volume - volume < value:
		value = max_volume - volume
	if value<0:
		for i in range(all_solution.size() - 1, -1, -1):
			if all_solution[i].volume > 0:
				all_solution[i].decrease_volume(-value)
				particle.modulate = OPERATIONS.generate_color(all_solution[i].el_composition)
				break
	else:
		for i in all_solution:
			if i.solvent == solvent:
				i.combine(value, concentration)
	for i in all_solution:
		if i.solvent != "Mixture" and i.volume > 5.0:
			all_solution[0].separate(i)
	volume += value
	dissolve()
	draw_volume()
	
func purge() -> void:
	print("purged")
	
	for i in all_solution:
		i.decrease_volume(i.volume)
	volume = 0
	draw_volume()

func acidify() -> void:
	for i in all_solution:
		i.acidified = true
	
func dissolve() -> void:
	if solute.is_empty():
		return
	if all_solution[1].volume > 0.0:
		while not solute.is_empty():
			var s : Ingredient = solute.pop_front()
			all_solution[1].dissolve(s)
		solute.clear()

	if all_solution[0].volume > 0.0:
		while not solute.is_empty():
			var s : Ingredient = solute.pop_front()

			all_solution[1].dissolve(s)
		solute.clear()
	draw_volume()
	return
	
func generate_desc() -> String:
	var output := ""
	
	for solution in all_solution:
		if solution.volume <= 0.0:
			continue
		output+= "Layer %s: %dml\n" % [solution.solvent, solution.volume]
		for element in solution.amounts:
			for state in solution.amounts[element]:
				if solution.amounts[element][state] <= 0.0:
					continue
				output += "%s %s: %.2f \n" % [state, element, solution.amounts[element][state]]
	
	return output
func generate_default_name() -> String:
	if volume == 0.0:
		return "Empty"
	var n := ""
	var majors := []
	for i in total_comp:
		if total_comp[i] >=0.25:
			majors.append(i)
	for i in majors:
		n += i + " "
	var suffix := "Mixture"
	
	for i in all_solution:
		if i.solvent != "Mixture" and i.volume/volume >= 0.5:
			suffix = "Solution"
	n += suffix
	
	
	return n
func generate_comp_text() -> String:
	var output := "Composition: \n"
	for i in total_comp:
		if total_comp[i] > 0.0:
			output += i + ": %.2f" %(total_comp[i]*100) + "% "
	return output
func _on_area_2d_mouse_entered() -> void:
	
	mouse_in = true
	tally_effects()
	if UI_communicator:
		var n := item_name 
		if n == "":
			n = generate_default_name()
		UI_communicator.emit_signal("display_request", n, generate_comp_text(), generate_desc())


func _on_area_2d_mouse_exited() -> void:
	mouse_in = false
	if UI_communicator:
		UI_communicator.emit_signal("stop_display")

func _on_pour_receptor_area_entered(area: Area2D) -> void:
	print("Detected", area.name)
	#area.emit_signal("pourable", self)


func _on_beaker_area_pourable(beaker: Beaker) -> void:
	target_beaker = beaker
	print("pourable")


func _on_pour_receptor_area_exited(area: Area2D) -> void:
	print("here")
	area.emit_signal("pourable", null)


func _on_solute_level_body_entered(body: Node2D) -> void:
	if body is Ingredient and body.soluble:
		for i in $SoluteLevel.get_overlapping_bodies():
			if body is Ingredient and body.soluble:
				solute.append(i)
		dissolve()

func _on_solute_level_body_exited(body: Node2D) -> void:
	if body is Ingredient and body.soluble and not body.is_queued_for_deletion():
		for i in $SoluteLevel.get_overlapping_bodies():
			if body is Ingredient and body.soluble:
				solute.append(i)
