extends CharacterBody2D
class_name Mineral
const OPERATIONS := preload("res://Res/operations.tres")
var all_elements : Array[BaseElement]= []

#==Internals==
@export var gravity := 9.81
@export var drag_speed := 20.0
@export var push_force := 200.0
@export var blended_volume := 10
@export var item_name := 'Ing'
@export var powder : PackedScene

var mouse_in := false
var dragging := false
var mouse_offset := Vector2.ZERO
var active := true


var is_pushed := false
var is_vel_reset := true
var external_velocity := Vector2.ZERO
@export var UI_communicator : UICommunicator

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
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
	
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and mouse_in:
			dragging = true
			mouse_offset = position - get_global_mouse_position()
		else:
			dragging = false
			

func _on_area_2d_mouse_entered() -> void:
	mouse_in = true
	if UI_communicator:
		UI_communicator.display_request.emit(item_name, "", "")


func _on_area_2d_mouse_exited() -> void:
	mouse_in = false
	if UI_communicator:
		UI_communicator.emit_signal("stop_display")
