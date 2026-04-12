extends CharacterBody2D
class_name Beaker
@onready var liquid = $Glass/Water
@onready var glass = $Glass
@onready var beaker_area = $BeakerArea

@export var initial_volume := 0.0
@export var max_volume := 100.0
@export var push_force := 80.0

@export var gravity := 9.81
@export var drag_speed := 20.0
var mouse_in := false
var dragging := false
var pouring := false
var target_beaker : Beaker = null
var volume := 0.0 : set = set_volume

var mouse_offset := Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func set_volume(value: float):
	volume = clamp(value, 0, max_volume)
func _ready() -> void:
	volume = initial_volume
	draw_volume()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if pouring:
		change_volume(-0.1, true)
		if target_beaker and volume != 0:
			target_beaker.change_volume(0.1)
		#await get_tree().create_timer(0.1).timeout
	#liquid.position.y -= 0.1
	#liquid.position.y = clamp(liquid.position.y, 0, 64)
	#await get_tree().create_timer(0.1).timeout
	
func _physics_process(delta: float) -> void:
	if dragging:
		var target_pos := get_global_mouse_position() + mouse_offset
		var target_direction := target_pos - position
		velocity = target_direction * drag_speed
		
	else:
		if not is_on_floor():
			velocity.y += gravity * delta
		else:
			velocity = Vector2.ZERO
			for i in beaker_area.get_overlapping_bodies():
				if i is Ingredient:
					i.external_velocity = Vector2.ZERO
	for i in beaker_area.get_overlapping_bodies():
		if i is Ingredient:
			i.external_velocity = velocity
	move_and_slide()
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action("l_click"):
			if event.is_pressed() and mouse_in:
				dragging = true
				mouse_offset = position - get_global_mouse_position()
				for i in beaker_area.get_overlapping_bodies():
					if i is Ingredient and i.mouse_in:
						dragging = false
				
			else:
				dragging = false
		if event.is_action("r_click"):
			if event.is_pressed() and mouse_in:
				pouring = true
				rotate(-PI/2)
				draw_volume(true)
			elif mouse_in:
				rotate(PI/2)
				pouring = false
				draw_volume()
			else:
				pouring = false
	
			
func draw_volume(hori := false) -> void:
	if hori:
		liquid.position.y = 0
		liquid.position.x = -53 - ((volume/max_volume) * -53)
	else:
		liquid.position.x = 0
		liquid.position.y = 64 - (volume/max_volume) * 64

func change_volume(value : float, hori:=false) -> void:
	volume += value
	draw_volume(hori)

func _on_area_2d_mouse_entered() -> void:

	mouse_in = true


func _on_area_2d_mouse_exited() -> void:
	mouse_in = false


func _on_pour_receptor_area_entered(area: Area2D) -> void:
	area.emit_signal("pourable", self)


func _on_beaker_area_pourable(beaker: Beaker) -> void:
	target_beaker = beaker


func _on_pour_receptor_area_exited(area: Area2D) -> void:
	area.emit_signal("pourable", null)
