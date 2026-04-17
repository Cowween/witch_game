extends StaticBody2D
class_name Cauldron
const OPERATIONS := preload("res://Res/operations.tres")
@export var potion_scene : PackedScene
@export var brewing := false
@export var UI_communicator : UICommunicator
var bottle : BottleOfPotion = null
var potion : Potion
var is_set := false : set = set_is_set
var in_tap := false
var bottle_pos : Vector2

func set_is_set(value) -> void:
	is_set = value
	print("potion set")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_potion()
	bottle_pos = to_global($CupPos.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(potion.total_amount, " ", potion.el_composition)
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and in_tap and bottle and not bottle.is_complete:
			pour_potion()

func new_potion() -> void:
	potion = potion_scene.instantiate()
	add_child(potion)
	potion.amounts = OPERATIONS.get_empty_dict()
	potion.el_composition = OPERATIONS.get_composition_from_amount(potion.amounts)

func pour_potion() -> void:
	bottle.active = false
	potion.finish_brew()
	bottle.potion = potion
	bottle.is_complete = true
	potion.reparent(bottle)
	is_set = false
	new_potion()
	bottle.active = true
	print(bottle.potion.generic_name())

func simple_combine(_amount:Dictionary) -> void:
	for i in _amount:
		for j in _amount[i]:
			potion.amounts[i][j] = potion.amounts[i].get(j, 0) + _amount[i][j]
	potion.el_composition = OPERATIONS.get_composition_from_amount(potion.amounts)
	potion.total_amount = OPERATIONS.get_total_from_amount(potion.amounts)

func combine(vol:float, concentration:Dictionary) -> void:
	for i in concentration:
		for j in concentration[i]:
			potion.amounts[i][j] = potion.amounts[i].get(j, 0) + concentration[i][j] * vol
	potion.el_composition = OPERATIONS.get_composition_from_amount(potion.amounts)
	potion.total_amount = OPERATIONS.get_total_from_amount(potion.amounts)

func generate_desc() -> String:
	var output := ""
	output += "Total amount: %2f, " % potion.total_amount
	if not potion.cursed_elements.is_empty():
		output += "Cursed, "
	if potion.is_mental:
		output += "Affects: Mind, "
	elif potion.is_physical:
		output += "Affects: Body, "
	if is_set:
		output += "Attuned\n "
	output += "Purity: %2f, Strength: %d\n" % [potion.purity*100, potion.strength]
	for element in potion.el_composition:
		output += "%s: %2f%\n" % [element, potion.el_composition[element] * 100]
	return output
	
func _on_pour_receptor_body_entered(body: Node2D) -> void:
	if body is Beaker:
		body.target_cauldron = self


func _on_pour_receptor_body_exited(body: Node2D) -> void:
	if body is Beaker:
		body.target_cauldron = null


func _on_dissolve_area_body_entered(body: Node2D) -> void:
	if body is Ingredient:
		simple_combine(body.amounts)
		body.queue_free()


func _on_pour_area_body_entered(body: Node2D) -> void:
	if body is BottleOfPotion:
		bottle = body
		bottle.in_distillator = true
		bottle.distillator_pos = bottle_pos


func _on_pour_area_body_exited(body: Node2D) -> void:
	if body is BottleOfPotion:
		bottle.in_distillator = false
		bottle = null


func _on_tap_mouse_entered() -> void:
	in_tap = true


func _on_tap_mouse_exited() -> void:
	in_tap = false


func _on_click_area_mouse_entered() -> void:
	if UI_communicator:
		UI_communicator.emit_signal("display_request", "Cauldron", potion.generate_comp_text(), generate_desc())



func _on_click_area_mouse_exited() -> void:
	pass # Replace with function body.
