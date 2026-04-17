extends Node
class_name Potion

const OPERATIONS := preload("res://Res/operations.tres")
var total_amount := 0.0
var amounts : Dictionary[String, Dictionary]
var el_composition : Dictionary[String, float]
var is_physical := false
var is_mental := false
var is_set := false
var cursed_elements : Array[String]
var final_comp : Dictionary[String, float]
var majors : Array[String]
var purity := 0
var strength : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generic_name() -> String:
	var n := ""
	if strength < 3:
		n += "Weak"
	else:
		n += "Strong"
	for i in majors:
		n += i + " "
	n += "Potion"
	
	return n
	
func generate_desc() -> String:
	var output := ""
	
	if is_mental:
		output += "Affects: Mind\n"
	elif is_physical:
		output += "Affects: Body\n"
	else:
		output += "Doesn't affect anything, you made juice.\n"
	output += "Purity: %2f\nStrength: %d\n" % [purity*100, strength]
	
	return output
func generate_comp_text() -> String:
	var output := "Composition: "
	for i in el_composition:
		output += i + ": " + str(el_composition[i]*100) + "% "
	return output
func finish_brew() -> void:
	for i in el_composition:
		var x := i
		if i in cursed_elements:
			x = "Cursed " + i
		final_comp[x] = el_composition[i]
		if final_comp[x] >= 0.25:
			majors.append(x)
	for i in majors:
		purity += el_composition[i]
	
	if total_amount < OPERATIONS.STR_RANGE[0]:
		strength = 1
	elif total_amount > OPERATIONS.STR_RANGE[0] and total_amount < OPERATIONS.STR_RANGE[1]:
		strength = 2
	elif total_amount > OPERATIONS.STR_RANGE[1] and total_amount < OPERATIONS.STR_RANGE[2]:
		strength = 3
	elif total_amount > OPERATIONS.STR_RANGE[2] and total_amount < OPERATIONS.STR_RANGE[3]:
		strength = 4
	elif total_amount > OPERATIONS.STR_RANGE[3]:
		strength = 5
		
		
		
