extends CharacterBody2D
class_name Ingredient
const OPERATIONS := preload("res://Res/operations.tres")
var all_elements : Array[BaseElement]= []

#==Internals==
@export var gravity := 9.81
@export var drag_speed := 20.0
@export var push_force := 200.0
@export var blended_volume := 10
@export var item_name := 'Ing'

var mouse_in := false
var dragging := false
var mouse_offset := Vector2.ZERO
var amounts : Dictionary[String, Dictionary]
var el_composition : Dictionary[String, float]
var total_amount := 0.0
var is_pushed := false
var is_vel_reset := true
var external_velocity := Vector2.ZERO
@export var UI_communicator : UICommunicator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		if i is BaseElement:
			all_elements.append(i)
	for i in all_elements:
		if not i.type in amounts:
			amounts[i.type] = {}
		amounts[i.type][i.state] = amounts[i.type].get(i.state, 0) + i.moles
		total_amount += i.moles
	el_composition = OPERATIONS.get_composition_from_amount(amounts)
	#print(el_composition)

func _physics_process(delta: float) -> void:
	
	if dragging:
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
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and mouse_in:
			dragging = true
			mouse_offset = position - get_global_mouse_position()
		else:
			dragging = false
			
func chop() -> void:
	pass

func grind() ->  void:
	pass
	
func distill() -> void:
	pass
	
func blend() -> void:
	pass

func _on_area_2d_mouse_entered() -> void:
	mouse_in = true
	UI_communicator.emit_signal("display_request", item_name, el_composition, amounts)


func _on_area_2d_mouse_exited() -> void:
	mouse_in = false
