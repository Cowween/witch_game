extends Area2D

signal pourable(beaker: Beaker)

@export var selected_texture : Node2D
@export var not_selected : Node2D
@export var non_static : Array[Node2D]


func _on_mouse_entered() -> void:
	if selected_texture and not_selected:
		selected_texture.visible = true
		not_selected.visible = false
	if not non_static.is_empty():
		for i in non_static:
			i.material.set_shader_parameter("line_thickness", 1.0)


func _on_mouse_exited() -> void:
	if selected_texture and not_selected:
		selected_texture.visible = false
		not_selected.visible = true
	if not non_static.is_empty():
		for i in non_static:
			i.material.set_shader_parameter("line_thickness", 0.0)
