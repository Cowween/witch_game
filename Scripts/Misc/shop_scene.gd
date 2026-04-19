extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		if "UI_communicator" in i:
			i.UI_communicator = $UICommunicator


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
