extends StaticBody2D
class_name Mortar

var mouse_in := false
var target_mineral : Array[Mineral]
var target_ingredient : Array[Ingredient]
var inner_selected := false
var stage := 0
var animation :=  true
@export var powder : PackedScene
@export var paste : PackedScene
@export var UI_communicator : UICommunicator
@export var launch_force := Vector2(-200, -600)
@onready var pestle := $Pestle
@onready var sound := $Scrape1
@onready var pop := $Pop
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func grind() -> bool:
	print(stage)
	pestle.play("Grind")
	sound.play()
	await pestle.animation_finished
	pestle.frame = 0
	match stage:
		0:
			for m in target_mineral:
				m.active = false
				m.apply_scale(Vector2(0.8,0.8))
			for m in target_ingredient:
				m.active = false
				m.apply_scale(Vector2(0.8,0.8))
		1:
			for m in target_mineral:
				m.apply_scale(Vector2(0.8,0.8))
			for m in target_ingredient:
				m.active = false
				m.apply_scale(Vector2(0.8,0.8))
		2:
			for m in target_mineral:
				m.apply_scale(Vector2(0.8,0.8))
			for m in target_ingredient:
				m.active = false
				m.apply_scale(Vector2(0.8,0.8))
		3:
			var final_res : Ingredient = powder.instantiate()
			var final_paste : Ingredient = paste.instantiate()
			var is_paste := false
			get_tree().current_scene.add_child(final_res)
			get_tree().current_scene.add_child(final_paste)
			while not target_mineral.is_empty():
				var m : Mineral = target_mineral.pop_front()
				var new_ing : Ingredient = m.powder.instantiate()
				m.queue_free()
				add_child(new_ing)
				if not new_ing.soluble:
					final_res.soluble = false
				final_res.combine(new_ing.amounts, new_ing.blended_volume)
				new_ing.queue_free()
			target_mineral.clear()
			while not target_ingredient.is_empty():
				var i : Ingredient = target_ingredient.pop_front()
				if i.is_powder:
					final_res.combine(i.amounts, i.blended_volume)
				else:
					is_paste = true
					final_paste.combine(i.amounts,i.blended_volume)
				i.queue_free()
			target_ingredient.clear()
			if is_paste:
				final_paste.combine(final_res.amounts, final_res.blended_volume)
				final_res.queue_free()
				final_res = final_paste
			else:
				final_paste.queue_free()
			final_res.global_position = to_global($IngredientSpawn.position)
			final_res.UI_communicator = UI_communicator
			final_res.sprite.modulate = final_res.OPERATIONS.generate_color(final_res.el_composition)
			await get_tree().create_timer(0.1).timeout
			pop.play()
			final_res.velocity += launch_force
	return true
			
	
func _input(event: InputEvent) -> void:
			
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and mouse_in and stage < 4 and animation:
			if not target_mineral.is_empty() or not target_ingredient.is_empty():
				animation = false
				animation = await grind()
				stage += 1
				if stage == 4:
					await get_tree().create_timer(2).timeout
					stage = 0

func _on_clickable_area_mouse_entered() -> void:
	mouse_in = true
	if UI_communicator:
		UI_communicator.display_request.emit("Mortar", "", "")
	#print("Entered")

func get_minerals(area: Area2D) -> Array[Mineral]:
	var ingredients : Array[Mineral] = []
	for i in area.get_overlapping_bodies():
		if i is Mineral:
			ingredients.append(i)
	
	return ingredients

func get_ingredients(area: Area2D) -> Array[Ingredient]:
	var ingredients : Array[Ingredient] = []
	for i in area.get_overlapping_bodies():
		if i is Ingredient:
			ingredients.append(i)
	
	return ingredients

func _on_clickable_area_mouse_exited() -> void:
	mouse_in = false
	if UI_communicator:
		UI_communicator.stop_display.emit()
	#print("exited")


func _on_container_body_entered(body: Node2D) -> void:
	if body is Mineral and not body.is_queued_for_deletion():
		print(body)
		target_mineral = get_minerals($Container)
	if body is Ingredient and not body.is_queued_for_deletion():
		target_ingredient = get_ingredients($Container)


func _on_container_body_exited(body: Node2D) -> void:
	if body is Mineral and not body.is_queued_for_deletion():
		target_mineral = get_minerals($Container)
	if body is Ingredient and not body.is_queued_for_deletion():
		target_ingredient = get_ingredients($Container)
