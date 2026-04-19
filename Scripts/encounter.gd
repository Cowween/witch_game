extends Node
class_name Encounter

@export var finished_dialogue : DialogueResource
@export var all_dialogues : Array[DialogueResource]
@export var error_dialogue : Array[DialogueResource]
@export var sprite : Sprite2D
@export var req_potion : PotionChecker
@export var dialogue_ui : DialogueUI
@export var encounter_manager : EncounterManager
@export var expressions : Array[Texture2D]

@export var travel_distance: float = 400.0 
@export var anim_speed: float = 0.5
var center_pos: Vector2
var bell : Node2D
func _ready() -> void:
	# Record where the sprite is placed in the editor so we can return to it
	if sprite:
		center_pos = sprite.position
	sprite.position.y += 999
func begin() -> void:
	dialogue_ui.clear_dialogue()
	show_next_dialogue()
		
func end() -> void:
	# Notice we pass 'self' as the second argument now
	dialogue_ui.show_dialogue(finished_dialogue, self)

func show_next_dialogue() -> void:
	var next_diag : DialogueResource = all_dialogues.pop_front()
	dialogue_ui.show_dialogue(next_diag, self)

func show_wrong(n: int) -> void:
	dialogue_ui.show_dialogue(error_dialogue[n], self)
func enter_right() -> void:
	if not sprite: return
	
	# Teleport the sprite off-screen to the right
	sprite.position = center_pos + Vector2(travel_distance, 0)
	
	var tween = create_tween()
	# TRANS_CUBIC with EASE_OUT creates a smooth, decelerating slide into view
	tween.tween_property(sprite, "position", center_pos, anim_speed)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)

func exit_left() -> void:
	if not sprite: return
	
	var tween = create_tween()
	# Calculate the position off-screen to the left
	var left_pos = center_pos + Vector2(-travel_distance, 0)
	
	# EASE_IN makes them start slow and accelerate as they leave the screen
	tween.tween_property(sprite, "position", left_pos, anim_speed)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_IN)
func enter_left() -> void:
	print("here")
	if not sprite: return
	sprite.position = center_pos + Vector2(-travel_distance, 0)
	var tween = create_tween()
	tween.tween_property(sprite, "position", center_pos, anim_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func rise_up() -> void:
	if not sprite: return
	sprite.position = center_pos + Vector2(0, travel_distance)
	var tween = create_tween()
	tween.tween_property(sprite, "position", center_pos, anim_speed).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func duck_down() -> void:
	if not sprite: return
	var tween = create_tween()
	var hidden_pos = center_pos + Vector2(0, travel_distance)
	tween.tween_property(sprite, "position", hidden_pos, anim_speed).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

func exit_right() -> void:
	if not sprite: return
	var tween = create_tween()
	var right_pos = center_pos + Vector2(travel_distance, 0)
	tween.tween_property(sprite, "position", right_pos, anim_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
func enter_top() -> void:
	if not sprite: return
	
	# Teleport the sprite high above the center position
	sprite.position = center_pos + Vector2(0, -travel_distance)
	
	var tween = create_tween()
	
	# TRANS_BACK is perfect for flying characters — it makes them swoop down, 
	# dip slightly past the target, and smoothly bounce back into place.
	tween.tween_property(sprite, "position", center_pos, anim_speed)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_OUT)
func show_express(num: int) -> void:
	sprite.texture = expressions[num]
	
func exit_up() -> void:
	if not sprite: return
	
	# The target position is high above the screen
	var target_pos = center_pos + Vector2(0, -travel_distance)
	
	var tween = create_tween()
	
	# TRANS_BACK with EASE_IN makes them dip down slightly before flying up
	tween.tween_property(sprite, "position", target_pos, anim_speed)\
		.set_trans(Tween.TRANS_BACK)\
		.set_ease(Tween.EASE_IN)
func rise_halfway() -> void:
	if not sprite: return
	
	# Teleport fully hidden below the window
	sprite.position = center_pos + Vector2(0, travel_distance)
	
	var tween = create_tween()
	
	# Calculate halfway point (change 0.5 to 0.6 or 0.4 if they need to peek more/less)
	var peek_pos = center_pos + Vector2(0, travel_distance*0.1)
	
	# Make it take 2.5x longer than a normal animation, easing out softly
	tween.tween_property(sprite, "position", peek_pos, anim_speed*2.5)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)
func shake() -> void:
	if not sprite: return
	var tween = create_tween()
	var og_x = center_pos.x # Use center_pos so it doesn't drift
	var offset = 15.0
	var spd = 0.05
	
	tween.tween_property(sprite, "position:x", og_x - offset, spd)
	tween.tween_property(sprite, "position:x", og_x + offset, spd)
	tween.tween_property(sprite, "position:x", og_x - offset, spd)
	tween.tween_property(sprite, "position:x", og_x + offset, spd)
	tween.tween_property(sprite, "position:x", og_x, spd)
	
func ring() -> void:
	bell.ring()
