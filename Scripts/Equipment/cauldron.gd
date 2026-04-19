extends StaticBody2D
class_name Cauldron
const OPERATIONS := preload("res://Res/operations.tres")
@export var potion_scene : PackedScene
@export var brewing := true
@export var UI_communicator : UICommunicator
@onready var particles := $GPUParticles2D
var bottle : BottleOfPotion = null
var potion : Potion
var is_set := false : set = set_is_set
var in_tap := false
var bottle_pos : Vector2
@onready var liquid := $AnimatedSprite2D
@onready var splash := $Splash
@onready var enchant := $Enchant
@onready var glow := $Glow

func set_is_set(value) -> void:
	is_set = value
	if is_set:
		glow.show()
		glow.play("default")
	else:
		glow.hide()
	print("potion set")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_potion(false)
	bottle_pos = to_global($CupPos.position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(potion.total_amount, " ", potion.el_composition)
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and in_tap and bottle and not bottle.is_complete:
			pour_potion()

func new_potion(d:bool=true) -> void:
	potion = potion_scene.instantiate()
	add_child(potion)
	potion.amounts = OPERATIONS.get_empty_dict()
	potion.el_composition = OPERATIONS.get_composition_from_amount(potion.amounts)
	if d:
		var tween := create_tween()
		tween.tween_property(liquid, "modulate", Color.ALICE_BLUE, 5.0)

func pour_potion() -> void:
	bottle.active = false
	potion.finish_brew()
	bottle.potion = potion
	particles.emitting = true
	particles.modulate = OPERATIONS.generate_color(potion.el_composition)
	bottle.is_complete = true
	is_set = false
	await bottle.fill_up()
	particles.emitting = false
	potion.reparent(bottle)
	
	new_potion()
	bottle.active = true
	print(bottle.potion.generic_name())

func simple_combine(_amount:Dictionary) -> void:
	for i in _amount:
		for j in _amount[i]:
			potion.amounts[i][j] = potion.amounts[i].get(j, 0) + _amount[i][j]
	potion.el_composition = OPERATIONS.get_composition_from_amount(potion.amounts)
	potion.total_amount = OPERATIONS.get_total_from_amount(potion.amounts)
	draw_liquid()

func combine(vol:float, concentration:Dictionary) -> void:
	for i in concentration:
		for j in concentration[i]:
			potion.amounts[i][j] = potion.amounts[i].get(j, 0) + concentration[i][j] * vol
	potion.el_composition = OPERATIONS.get_composition_from_amount(potion.amounts)
	potion.total_amount = OPERATIONS.get_total_from_amount(potion.amounts)
	draw_liquid()

func generate_desc() -> String:
	var output := ""
	potion.get_majors()
	potion.get_purity()
	potion.get_strength()
	print(potion.majors)
	output += "Total amount: %.2f, " % potion.total_amount
	if not potion.cursed_elements.is_empty():
		output += "Cursed, "
	if potion.is_mental:
		output += "Cauldron is set. Attuned to: Mind, "
	elif potion.is_physical:
		output += "Cauldron is set. Attuned to: Body, "

	output += "Purity: %.2f, Strength: %d\n" % [potion.purity*100, potion.strength]
	for element in potion.el_composition:
		if potion.el_composition[element]>0.0:
			if element in potion.cursed_elements:
				output += "Cursed "
			output += "%s: %.2f%%\n" % [element, (potion.el_composition[element] * 100)]
	return output
func play_enchant() -> void:
	enchant.show()
	enchant.play("default")
	await enchant.animation_finished
	enchant.hide()
func draw_liquid() -> void:
	liquid.modulate = OPERATIONS.generate_color(potion.el_composition)
	splash.modulate = OPERATIONS.generate_color(potion.el_composition)

func _on_pour_receptor_body_entered(body: Node2D) -> void:
	if body is Beaker:
		body.target_cauldron = self


func _on_pour_receptor_body_exited(body: Node2D) -> void:
	if body is Beaker:
		body.target_cauldron = null


func _on_dissolve_area_body_entered(body: Node2D) -> void:
	if body.is_queued_for_deletion():
		return
	if not body:
		return
	if body is Ingredient:
		simple_combine(body.amounts)
		body.queue_free()
		splash.show()
		splash.play("default")
		await splash.animation_finished
		splash.stop()
		splash.hide()
		return
	if body is Beaker and body is not BottleOfPotion:
		for i in body.all_solution:
			simple_combine(i.amounts)
		body.queue_free()
		splash.show()
		splash.play("default")
		await splash.animation_finished
		splash.stop()
		splash.hide()
		return
	if body is Mineral:
		var ing = body.powder.instantiate()
		add_child(ing)
		simple_combine(ing.amounts)
		ing.queue_free()
		body.queue_free()
		splash.show()
		splash.play("default")
		await splash.animation_finished
		splash.stop()
		splash.hide()
		return
	


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
	if UI_communicator:
		UI_communicator.stop_display.emit()
