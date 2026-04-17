extends Area2D

@export var ingredient : PackedScene
@export var UI_communicator : UICommunicator
@export var non_static : Array[Node2D]
var mouse_in := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and mouse_in:
			var new_ing := ingredient.instantiate()
			new_ing.UI_communicator = UI_communicator
			#new_ing.dragging = true
			get_tree().current_scene.add_child(new_ing)
			new_ing.position = get_global_mouse_position()
			new_ing.dragging = true
			new_ing.mouse_offset = new_ing.position - get_global_mouse_position()


func _on_mouse_entered() -> void:
	mouse_in = true
	if not non_static.is_empty():
		for i in non_static:
			i.material.set_shader_parameter("line_thickness", 1.0)


func _on_mouse_exited() -> void:
	mouse_in = false
	if not non_static.is_empty():
		for i in non_static:
			i.material.set_shader_parameter("line_thickness", 0.0)
