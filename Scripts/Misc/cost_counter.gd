extends Node
class_name CostCounter
var total_cost := 0 : set = set_cost
var total_gain := 0 : set = set_gain

func set_cost(value) -> void:
	total_cost = value
	$VBoxContainer/HBoxContainer/Cost.text = "Cost: [color=red]%d[/color]" % total_cost
	
	
func set_gain(value) -> void:
	total_gain = value
	$VBoxContainer/HBoxContainer2/Gain.text = "Gain: [color=green]%d[/color]" % total_gain
