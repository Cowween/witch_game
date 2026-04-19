extends TextureButton
@export var texture : Texture2D
@export var ingredient : PackedScene
@export var cost : int
var cost_counter : CostCounter
var item_name : String
var composition : String
var amounts : String
@export var desc := ""
var UI_communicator : UICommunicator
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$TextureRect.texture = texture
	if ingredient:
		var temp := ingredient.instantiate()
		add_child(temp)
		if temp is Ingredient:
			amounts = temp.generate_desc()
			
			composition = temp.generate_comp_text()
		item_name = temp.item_name
		temp.queue_free()

	


func _on_button_down() -> void:
	var new_ing := ingredient.instantiate()
	new_ing.UI_communicator = UI_communicator
	cost_counter.total_cost += cost
	#new_ing.dragging = true
	get_tree().current_scene.add_child(new_ing)
	new_ing.position = get_global_mouse_position()
	new_ing.dragging = true
	new_ing.mouse_offset = new_ing.position - get_global_mouse_position()


func _on_mouse_entered() -> void:
	UI_communicator.display_request.emit(item_name, composition, desc+"\n"+amounts + "\nCost: " + str(cost))


func _on_mouse_exited() -> void:
	UI_communicator.stop_display.emit()
