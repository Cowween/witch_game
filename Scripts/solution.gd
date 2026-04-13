extends Node
class_name Solution
const ELEMENTS := ["Wood", "Fire", "Water", "Earth", "Metal"]
const STATES := ["Polar", "Non-polar", "Salt", "Elemental"]
const OPERATIONS := preload("res://Res/operations.tres")

var amounts : Dictionary[String, Dictionary]
var conc : Dictionary[String, Dictionary]
@export var volume := 0.0 : set = set_volume
var el_composition : Dictionary[String, float]
@export var is_polar := false
@export var is_non_polar := false
@export var is_salt := false
@export var is_mixture := false
@export var acidified := false
@export_enum("Polar", "Non-polar", "Salt", "Mixture") var solvent: String
func set_volume(value: float) -> void:
	volume = clamp(value, 0, 9999)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	amounts = OPERATIONS.get_empty_dict()
	conc = OPERATIONS.get_empty_dict()

func calculate_conc() -> void:
	for i in amounts:
		for j in amounts[i]:
			conc[i][j] = amounts[i][j]/volume
	#print(conc)
func decrease_volume(dec: float) -> void:
	print(amounts)
	volume -= dec
	for i in conc:
		for j in conc[i]:
			amounts[i][j] = amounts[i].get(j, 0) - conc[i][j] * dec

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
	target.calculate_conc()
				
func combine(vol:float, concentration:Dictionary) -> void:
	volume += vol
	for i in concentration:
		for j in concentration[i]:
			amounts[i][j] = amounts[i].get(j, 0) + concentration[i][j] * vol
	calculate_conc()
	el_composition = OPERATIONS.get_composition_from_amount(amounts)
