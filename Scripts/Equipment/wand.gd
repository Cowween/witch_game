extends CharacterBody2D
class_name Wand

@export var drag_speed := 20.0
@export var spell_interface : SpellInterface
@export var cauldron : Cauldron

@export var physical_spell := "abcd"
@export var mental_spell := "dcba"
@export var curse_spell := "curse"

var spells : Dictionary[String, Callable] = {
	physical_spell: set_physical,
	mental_spell: set_mental,
	curse_spell: curse
}
var dragging := false
var mouse_in := false
var active := true
var left := false
var mouse_offset := Vector2.ZERO
var initial_pos : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	initial_pos = position

	
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
				mouse_offset = position - get_global_mouse_position()

				
			else:
				dragging = false
				
func set_physical() -> void:
	if cauldron.is_set:
		return
	cauldron.is_set = true
	cauldron.potion.is_set = true
	cauldron.potion.is_physical = true
	
func set_mental() -> void:
	if cauldron.is_set:
		return
	cauldron.is_set = true
	cauldron.potion.is_set = true
	cauldron.potion.is_mental = true

func curse() -> void:
	for i in cauldron.potion.el_composition:
		if cauldron.potion.el_composition[i] > 0.0:
			cauldron.potion.cursed_elements.append(i)

func cast(s: String) -> void:
	spells[s].call()

func _on_click_area_mouse_entered() -> void:
	mouse_in = true


func _on_click_area_mouse_exited() -> void:
	mouse_in = false


func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body == cauldron and cauldron.brewing:
		active = false
		spell_interface.begin_spell()


func _on_spell_interface_spell_inputted(spell: String) -> void:
	cast(spell.to_lower())
	active = true
