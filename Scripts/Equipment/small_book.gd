extends Area2D


# Called when the node enters the scene tree for the first time.

@export var selected_texture : Node2D
@export var not_selected : Node2D
@export var non_static : Array[Node2D]
@export var book: Book
var mouse_in := false
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and mouse_in:
			book.open_book()
func _on_mouse_entered() -> void:
	mouse_in = true
	if selected_texture and not_selected:
		selected_texture.visible = true
		not_selected.visible = false
	if not non_static.is_empty():
		for i in non_static:
			i.material.set_shader_parameter("line_thickness", 1.0)


func _on_mouse_exited() -> void:
	mouse_in = false
	if selected_texture and not_selected:
		selected_texture.visible = false
		not_selected.visible = true
	if not non_static.is_empty():
		for i in non_static:
			i.material.set_shader_parameter("line_thickness", 0.0)
