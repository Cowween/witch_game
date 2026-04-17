extends StaticBody2D

const OPERATIONS := preload("res://Res/operations.tres")

@onready var cup := $BlenderCup

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
	$Cap.visible = true
	initial_pos = cup.position
	cup.UI_communicator = UI_communicator
	cup.max_volume = capacity
	volume = 0.0
	


# Called every frame. 'delta' is the elapsed time since the previous frame.

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
			$Cap.visible = true
			var current_vol := volume + resulting_vol/3
			cup.mixture.volume = current_vol
			
			volume = current_vol
			cup.twig.play("default")
			await cup.twig
			for i in ingredients:
				i.apply_scale(Vector2(0.8,0.8))
			cup.twig.frame = 0
			
		1:
			var current_vol := volume + resulting_vol/3
			cup.mixture.volume = current_vol

			volume = current_vol
			cup.twig.play("default")
			await cup.twig
			cup.twig.frame = 0
			
		2:
			volume = volume + resulting_vol/3
			print("Final vol", volume)
			for i in ingredients:
				i.queue_free()
			cup.twig.play("default")
			await cup.twig
			cup.twig.frame = 0
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
		if event.is_pressed and inner_selected:
			$LidCollider.set_deferred("disabled", true) 
			$Cap.visible = false
		elif event.is_released() and inner_selected:
			$LidCollider.set_deferred("disabled", false) 
			$Cap.visible = true
		if event.is_pressed() and mouse_in and not inner_selected:
			if not get_ingredients($Area2D).is_empty():
				blend(stage)
				stage += 1
				if stage == 3:
					stage = 0

func _on_area_2d_mouse_entered() -> void:
	mouse_in = true
	
	


func _on_area_2d_mouse_exited() -> void:
	mouse_in = false


func _on_blender_cup_volume_updated() -> void:
	volume = cup.volume


func _on_mouth_area_body_entered(body: Node2D) -> void:
	if body is Ingredient:
		$Cap.visible = false
		$LidCollider.set_deferred("disabled", true) 
		print($LidCollider.disabled)


func _on_mouth_area_body_exited(body: Node2D) -> void:
	if body is Ingredient:
		$Cap.visible = true
		$LidCollider.set_deferred("disabled", false) 


func _on_blender_cup_back() -> void:
	$Cap.visible = true


func _on_blender_cup_moving() -> void:
	$Cap.visible = false
