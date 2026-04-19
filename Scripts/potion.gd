extends Node
class_name Potion

const OPERATIONS := preload("res://Res/operations.tres")
var total_amount := 0.0
var amounts : Dictionary[String, Dictionary]
var el_composition : Dictionary[String, float]
@export var is_physical := false
@export var is_mental := false
@export var is_set := false
var cursed_elements : Array[String]
var final_comp : Dictionary[String, float]
@export var majors : Array[String]
@export var purity := 0.0
@export var strength := 1
var final := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func generic_name() -> String:
	get_majors(true)
	var n := ""
	print(cursed_elements, majors)
	match strength:
		1: 
			n += "Weak "
		2:
			n+= "Subtle "
		3:
			n+= "Standard "
		4: 
			n += "Strong "
		5:
			n +=  "Epitome "
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
	output += "Purity: %.2f\nStrength: %d\n" % [purity*100, strength]
	
	return output
func generate_comp_text() -> String:
	var output := "Composition: "
	var comp := el_composition
	if final: comp = final_comp
	
	for i in comp:
		if comp[i]>0:
			output += i + ": %.2f"  %(comp[i]*100) + "% "
	return output
func get_purity() -> void:
	purity = 0.0
	for i in majors:
	
		purity += el_composition[i]
		print(purity)

func get_strength() -> void:
	if total_amount <= OPERATIONS.STR_RANGE[0]:
		strength = 1
	elif total_amount > OPERATIONS.STR_RANGE[0] and total_amount <= OPERATIONS.STR_RANGE[1]:
		strength = 2
	elif total_amount > OPERATIONS.STR_RANGE[1] and total_amount <= OPERATIONS.STR_RANGE[2]:
		strength = 3
	elif total_amount > OPERATIONS.STR_RANGE[2] and total_amount <= OPERATIONS.STR_RANGE[3]:
		strength = 4
	elif total_amount > OPERATIONS.STR_RANGE[3]:
		strength = 5
func get_majors(use_curse:= false) -> void:
	majors = []
	final_comp = {}
	for i in el_composition:
		var x := i
		if i in cursed_elements and use_curse:
			x = "Cursed " + i
		final_comp[x] = el_composition[i]
		if final_comp[x] >= 0.25:
			majors.append(x)
func finish_brew() -> void:
	get_majors()
	get_purity()
	get_majors(true)
	get_strength()
	final = true
	
		
		
		
