extends Node
class_name Solution
const ELEMENTS := ["Wood", "Fire", "Water", "Earth", "Metal", "Junk"]
const STATES := ["Polar", "Non-polar", "Salt", "Elemental"]
const OPERATIONS := preload("res://Res/operations.tres")

var amounts : Dictionary[String, Dictionary]
var conc : Dictionary[String, Dictionary]

@export var volume := 0.0 : set = set_volume
var el_composition : Dictionary[String, float]
var max_volume  := 999
@export var is_polar := false
@export var is_non_polar := false
@export var is_salt := false
@export var is_mixture := false
@export var is_elixir := false
@export var acidified := false
@export_enum("Polar", "Non-polar", "Salt", "Mixture", "Elixir") var solvent: String
func set_volume(value: float) -> void:
	volume = clamp(value, 0, max_volume)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	amounts = OPERATIONS.get_empty_dict()
	conc = OPERATIONS.get_empty_dict()
	var all_elements : Array[BaseElement]
	for i in get_children():
		if i is BaseElement:
			all_elements.append(i)
	for i in all_elements:
		if not i.type in amounts:
			amounts[i.type] = {}
		amounts[i.type][i.state] = amounts[i.type].get(i.state, 0) + i.moles
	el_composition = OPERATIONS.get_composition_from_amount(amounts)

func calculate_conc() -> void:
	for i in amounts:
		for j in amounts[i]:
			conc[i][j] = amounts[i][j]/volume
	#print(conc)
func decrease_volume(dec: float) -> void:
	volume -= dec
	for i in conc:
		for j in conc[i]:
			if volume == 0.0:
				amounts[i][j] = 0.0
				conc[i][j] = 0.0
				continue
			amounts[i][j] = amounts[i].get(j, 0) - conc[i][j] * dec
	el_composition = OPERATIONS.get_composition_from_amount(amounts)

func separate(target: Solution) -> void:
	if not is_mixture:
		return
	var _solvent := target.solvent
	var target_amounts := target.amounts
	for element in amounts:
		for state in amounts[element]:
			if state == _solvent:
				target_amounts[element][state] += amounts[element][state]
				amounts[element][state] = 0
			elif target.acidified and state == "Elemental":
				target_amounts[element]["Salt"] += amounts[element][state]
				amounts[element][state] = 0
	calculate_conc()
	el_composition = OPERATIONS.get_composition_from_amount(amounts)
	target.calculate_conc()
				
func decrease_element(element: String, quant: float) -> void:			
	print("decrease", element, "by", quant)
	var no_non_empty := 0
	for i in amounts[element].values():
		if i > 0.0:
			no_non_empty += 1
	quant = quant / no_non_empty
	for i in amounts[element]:
		if amounts[element][i] > 0.0:
			amounts[element][i] -= quant
	calculate_conc()
	el_composition = OPERATIONS.get_composition_from_amount(amounts)

func dissolve(ing: Ingredient) -> void:
	simple_combine(ing.amounts)
	ing.queue_free()
func simple_combine(_amount:Dictionary) -> void:
	for i in _amount:
		for j in _amount[i]:
			amounts[i][j] = amounts[i].get(j, 0) + _amount[i][j]
	calculate_conc()
	el_composition = OPERATIONS.get_composition_from_amount(amounts)
func combine(vol:float, concentration:Dictionary) -> void:
	if max_volume - volume < vol:
		vol = max_volume - volume
	volume += vol
	for i in concentration:
		for j in concentration[i]:
			amounts[i][j] = amounts[i].get(j, 0) + concentration[i][j] * vol
	calculate_conc()
	el_composition = OPERATIONS.get_composition_from_amount(amounts)
