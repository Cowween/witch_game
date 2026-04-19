extends PanelContainer
class_name End
@export var next_scene_path : PackedScene

func _ready() -> void:
	hide()
func show_end(cost:int, gain:int) -> void:
	if not next_scene_path:
		$VBoxContainer/Button.text = "The End"
	$VBoxContainer/RichTextLabel.text = "Total cost: %d\nTotal gain: %d\nTotal profit: %d" % [cost,  gain, gain-cost]
	show()

func _on_button_pressed() -> void:
	if next_scene_path:
		get_tree().change_scene_to_packed(next_scene_path)
