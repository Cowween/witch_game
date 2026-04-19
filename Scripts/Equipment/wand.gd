extends CharacterBody2D
class_name Wand

@export var drag_speed := 20.0
@export var spell_interface : SpellInterface
@export var cauldron : Cauldron

@export var physical_spell := "abcd"
@export var mental_spell := "dcba"
@export var curse_spell := "curse"
@export var purge_spell := "purge"
var spells : Dictionary[String, Callable] 
var dragging := false
var mouse_in := false
var active := true
var left := false
var in_cauldron := false
var mouse_offset := Vector2.ZERO
var initial_pos : Vector2
var current_beaker : Beaker = null
var castable := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_pos = position
	print(spells)
	spells = {
	physical_spell: set_physical,
	mental_spell: set_mental,
	curse_spell: curse,
	purge_spell: purge 
	}

	
func _physics_process(delta: float) -> void:
	if active:
		if dragging:
			var target_pos := get_global_mouse_position() + mouse_offset
			var target_direction := target_pos - position
			velocity = target_direction * drag_speed
			
		else:
			var target_direction := initial_pos - position
			velocity = target_direction * drag_speed
			if initial_pos.distance_to(position) <= 0.5 and left:
				left = false

		move_and_slide()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action("l_click"):
			if event.is_pressed() and mouse_in:
				dragging = true
				left = true
				visibility_layer = 5
				mouse_offset = position - get_global_mouse_position()

				
			else:
				visibility_layer = 1
				dragging = false
		if event.is_action("r_click"):
			if event.is_pressed() and castable:
				active = false
				spell_interface.begin_spell()
func set_physical() -> void:
	if cauldron.is_set:
		return
	cauldron.is_set = true
	cauldron.potion.is_set = true
	cauldron.potion.is_physical = true
	cauldron.play_enchant()
	
func set_mental() -> void:
	if cauldron.is_set:
		return
	cauldron.is_set = true
	cauldron.potion.is_set = true
	cauldron.potion.is_mental = true
	cauldron.play_enchant()

func curse() -> void:
	for i in cauldron.potion.el_composition:
		if cauldron.potion.el_composition[i] > 0.0 and i not in cauldron.potion.cursed_elements:
			cauldron.potion.cursed_elements.append(i)
	cauldron.play_enchant()

func purge() -> void:
	if current_beaker:
		current_beaker.purge()

func cast(s: String) -> void:
	if s in spells:
		spells[s].call()

func _on_click_area_mouse_entered() -> void:
	mouse_in = true


func _on_click_area_mouse_exited() -> void:
	mouse_in = false


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body == cauldron and cauldron.brewing:
		castable = true
	if body is Beaker:
		current_beaker = body
		castable = true


func _on_spell_interface_spell_inputted(spell: String) -> void:
	cast(spell.to_lower())
	active = true
	castable = false


func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body == cauldron:
		castable = false
		print("false")
	if body is Beaker:
		current_beaker = null
		castable = false
