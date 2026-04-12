extends CharacterBody2D
class_name Ingredient

var all_elements : Array[BaseElement]= []

#==Internals==
@export var gravity := 9.81
@export var drag_speed := 20.0
@export var push_force := 200.0
var mouse_in := false
var dragging := false
var mouse_offset := Vector2.ZERO
var amounts : Dictionary[String, float]
var is_pushed := false
var is_vel_reset := true
var external_velocity := Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		if i is BaseElement:
			all_elements.append(i)
			amounts[i.type] = 0
	for i in all_elements:
		amounts[i.type] = i.moles + amounts[i.type]
	print(amounts)

func _physics_process(delta: float) -> void:
	
	if dragging:
		var target_pos := get_global_mouse_position() + mouse_offset
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


func _on_area_2d_mouse_exited() -> void:
	mouse_in = false
