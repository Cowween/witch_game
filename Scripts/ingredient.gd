extends CharacterBody2D
class_name Ingredient
const OPERATIONS := preload("res://Res/operations.tres")
var all_elements : Array[BaseElement]= []
@onready var sprite := $Sprite2D
#==Internals==
@export var gravity := 9.81
@export var drag_speed := 20.0
@export var push_force := 200.0
@export var blended_volume := 10
@export var item_name := 'Ing'
@export var soluble := false
@export var soluble_in_acid := false
@export var suffix := ""
@export var is_random := false

@export var is_powder := false
var mouse_in := false
var dragging := false
var mouse_offset := Vector2.ZERO
var amounts : Dictionary[String, Dictionary]
var el_composition : Dictionary[String, float]
var is_pushed := false
var is_vel_reset := true
var external_velocity := Vector2.ZERO
var active := true
@export var UI_communicator : UICommunicator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		if i is BaseElement:
			all_elements.append(i)
	amounts = OPERATIONS.get_empty_dict()
	for i in all_elements:
		amounts[i.type][i.state] = amounts[i.type].get(i.state, 0) + i.moles
	if is_random:
		var initial := 100
		for element in amounts:
			var s : String = amounts[element].keys().pick_random()
			amounts[element][s] = randi_range(0, initial)
			initial -= amounts[element][s]
	el_composition = OPERATIONS.get_composition_from_amount(amounts)
	#print(el_composition)

func _physics_process(delta: float) -> void:
	
	if dragging and active:
		var target_pos := get_global_mouse_position() + mouse_offset
		#print(mouse_offset)
		var target_direction := target_pos - position
		velocity = target_direction * drag_speed
		for i in get_slide_collision_count():
			var collision := get_slide_collision(i)
			var collider := collision.get_collider()
			if collider is Ingredient:
				collider.velocity = velocity.project(-collision.get_normal())
				collider.move_and_slide()
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
			is_vel_reset = false
		else:
			if not is_vel_reset:
				external_velocity = Vector2.ZERO
			velocity.y = 0
			velocity.x = move_toward(velocity.x, 0, 500 * delta)


	
	velocity += external_velocity
	move_and_slide()
	velocity -= external_velocity
	
func combine(_amount:Dictionary, _vol: float) -> void:
	for i in _amount:
		for j in _amount[i]:
			amounts[i][j] = amounts[i].get(j, 0) + _amount[i][j]
	blended_volume += _vol
	el_composition = OPERATIONS.get_composition_from_amount(amounts)

func generate_default_name() -> String:
	var n := ""
	var majors := []
	for i in el_composition:
		if el_composition[i] >=0.25:
			majors.append(i)
	for i in majors:
		n += i + " "
	n += suffix
	
	return n

func generate_desc() -> String:
	var output := ""
	if soluble:
		output += "Soluble in aqua\n"
	for element in amounts:
			for state in amounts[element]:
				var c : String = OPERATIONS.COLORS_TEXT[element]
				if amounts[element][state] <= 0.0:
					continue
				output += "%s [color=%s]%s[/color]: %.2f \n" % [state, c, element, amounts[element][state]]
	
	return output

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and mouse_in:
			dragging = true
			mouse_offset = position - get_global_mouse_position()
		else:
			dragging = false

func generate_comp_text() -> String:
	var output := "Composition: \n"
	for i in el_composition:
		if el_composition[i] > 0.0:
			output += i + ": %.2f" % (el_composition[i]*100) + "% "
	return output

func _on_area_2d_mouse_entered() -> void:
	mouse_in = true
	if UI_communicator:
		var n := item_name
		if n == "":
			n = generate_default_name()
		UI_communicator.emit_signal("display_request", self, n, generate_comp_text(), generate_desc())


func _on_area_2d_mouse_exited() -> void:
	mouse_in = false
	if UI_communicator:
		UI_communicator.emit_signal("stop_display", self)
