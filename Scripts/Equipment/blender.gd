extends StaticBody2D

const OPEN_BLENDER := preload("res://Assets/TestAssets/blender1.png")
const CLOSED_BLENDER := preload("res://Assets/TestAssets/blender2.png")
const BLENDER_FULL_POS := -1.0
const BLENDER_EMPTY_POS := 97.0
const OPERATIONS := preload("res://Res/operations.tres")

@onready var cup := $BlenderCup
@onready var blender_texture := $BlenderTexture

@export var capacity := 100.0
@export var UI_communicator : UICommunicator
var amounts : Dictionary
var all_elements : Array[BaseElement]
var mouse_in := false
var inner_selected := false
var volume := 0.0 : set = set_volume
var stage := 0
var initial_pos : Vector2

func set_volume(value) -> void:
	volume = value
	cup.volume = value
	cup.draw_volume()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_pos = cup.position
	cup.empty_y = BLENDER_EMPTY_POS
	cup.full_y = BLENDER_FULL_POS
	cup.UI_communicator = UI_communicator
	cup.max_volume = capacity
	volume = 0.0
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func get_ingredients(area: Area2D) -> Array[Ingredient]:
	var ingredients : Array[Ingredient] = []
	for i in area.get_overlapping_bodies():
		if i is Ingredient:
			ingredients.append(i)
	
	return ingredients
func account(ingredients: Array[Ingredient]) -> Dictionary[String, Dictionary]:
	var _amounts := OPERATIONS.get_empty_dict()
	for i in ingredients:
		for element in i.all_elements:
			_amounts[element.type][element.state] = _amounts[element.type].get(element.state, 0) + element.moles
	return _amounts
func account_composition(a:Dictionary) -> Dictionary[String, float]:

	return OPERATIONS.get_composition_from_amount(a)
func account_volume(ingredients: Array[Ingredient]) -> float:
	var vol := 0.0
	for i in ingredients:
		vol += i.blended_volume
	return vol
func blend(blend_stage: int) -> void:
	var ingredients := get_ingredients($Area2D)
	var resulting_vol := account_volume(ingredients)
	cup.active = false
	match blend_stage:
		0:
			blender_texture.texture = CLOSED_BLENDER
		1:
			var current_vol := volume + resulting_vol/3
			cup.mixture.volume = current_vol

			volume = current_vol
			
		2:
			var current_vol := volume + resulting_vol/3
			cup.mixture.volume = current_vol

			volume = current_vol
			
		3:
			volume = volume + resulting_vol/3
			print("Final vol", volume)
			for i in ingredients:
				i.queue_free()
			blender_texture.texture = OPEN_BLENDER
			cup.active = true
			var resulting_amounts := account(ingredients)
			cup.mixture.volume = volume
			cup.mixture.amounts = resulting_amounts
			cup.mixture.el_composition = account_composition(resulting_amounts)
			cup.mixture.calculate_conc()
			
			
	
				
func _input(event: InputEvent) -> void:
	inner_selected = false
	for i in $Area2D.get_overlapping_bodies():
		if i is Ingredient and i.mouse_in:
			inner_selected = true
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and mouse_in and not inner_selected:
			if not get_ingredients($Area2D).is_empty():
				blend(stage)
				stage += 1
				if stage == 4:
					stage = 0

func _on_area_2d_mouse_entered() -> void:
	mouse_in = true
	


func _on_area_2d_mouse_exited() -> void:
	mouse_in = false


func _on_blender_cup_volume_updated() -> void:
	volume = cup.volume
