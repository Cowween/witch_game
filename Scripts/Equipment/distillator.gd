extends StaticBody2D

const OPERATIONS := preload("res://Res/operations.tres")
@export var initial_temp := 25.0
@export var temp_increment := 0.2
@export var boil_rate := 0.5
@export var wait_time := 0.2
@export var min_therm_height : float
@export var max_therm_height : float
@export var max_temp := 150.0

@export var flask_pos := Vector2.ZERO
@export var volume_decrease := 0.01
@export var UI_communicator : UICommunicator
@onready var sound := $Zipclick
@onready var timer := $Timer
@onready var red_liquid := $RedLiquid/Sprite2D
@onready var particles := $GPUParticles2D
@onready var funnel := $Funnel
var temperature := 25.0
var actual_increment : float
@export var flask : RoundBottomedFlask
var beaker : Beaker
var temp_extractable : Dictionary[float, String]
var temp_list : Array[float]
var mouse_in := false
var started := false :set = set_started
var beaker_in := false
var rock_in := false
var t_in := false
@onready var cork := $Distillcork

func set_started(value: bool) -> void:
	started = value
	if started:
		funnel.hide()
		sound.play()
		$SRock.frame = 0
		$URock.frame = 0
		timer.start()
		populate_extractable()
		cork.show()
		flask.open = false
	else:
		funnel.show()
		sound.play()
		flask.open = true
		$SRock.frame = 1
		$URock.frame = 1
		timer.stop()
		temp_extractable = {}
		cork.hide()
		var tween := create_tween()
		tween.tween_property(red_liquid, "position", Vector2(0, lerpf(min_therm_height, max_therm_height, initial_temp/max_temp)), 5.0)
		temperature = initial_temp

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	cork.hide()
	temperature = initial_temp
	timer.wait_time = wait_time
	actual_increment = temp_increment
	$SRock.frame = 1
	$URock.frame = 1
	red_liquid.position.y = lerpf(min_therm_height, max_therm_height, temperature/max_temp)
	flask.UI_communicator = UI_communicator

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and rock_in:
			if started:
				started = false
			else:
				started = true

func populate_extractable() -> void:
	flask.tally_effects()
	print(flask.total_comp)
	for i in flask.total_comp:
		if i == "Junk":
			continue
		if flask.total_comp[i] > 0.0:
			temp_extractable[OPERATIONS.DISTIL_TEMPS[i]] = i
	for i in temp_extractable:
		temp_list.append(i)
	temp_list.sort()
	#print(temp_extractable)
	#print(temp_list)
	
func extract_element(element:String, quant : float) -> bool:
	particles.modulate = OPERATIONS.COLORS[element]
	var usable : Array[Solution]
	for i in flask.all_solution:
		var temp := OPERATIONS.get_element_amount(element, i.amounts)
		print(element, " ", temp)
		if temp > 0.1:
			usable.append(i)
	if usable.is_empty():
		return true
	for i in usable:
		i.decrease_element(element, quant)
	if beaker:
		beaker.change_volume(quant, {element: {"Elemental": 1.0}}, "Elixir")
	flask.tally_effects()
	return false

func decrease_vol() -> void:
	for i in flask.all_solution:
		if i.volume > 0.0:
			i.volume -= volume_decrease
	flask.volume -= volume_decrease
	flask.draw_volume()

	
func distill() -> void:
	if temp_list.is_empty():
		particles.emitting = false
		return
	#print(temp_list)
	if temperature >= temp_list[0]:
		
		particles.emitting = true
		actual_increment = 0.0
		var is_finished := extract_element(temp_extractable[temp_list[0]], boil_rate)
		if is_finished:
			temp_list.pop_front()
			particles.emitting = false
			actual_increment = temp_increment
	else:
		particles.emitting = false
		actual_increment = temp_increment

func _on_click_area_mouse_entered() -> void:
	mouse_in = true
	if UI_communicator:
		UI_communicator.display_request.emit(self, "Distillator", "", "Click on the fire stone to begin distillation")


func _on_click_area_mouse_exited() -> void:
	mouse_in = false
	if UI_communicator:
		UI_communicator.stop_display.emit(self)


func _on_timer_timeout() -> void:
		
	distill()
	temperature += actual_increment
	red_liquid.position.y = lerpf(min_therm_height, max_therm_height, temperature/max_temp)
	if UI_communicator and t_in:
		UI_communicator.emit_signal("display_temperature", self, temperature)
	decrease_vol()
	




func _on_pour_area_body_entered(body: Node2D) -> void:
	if body and body is Beaker:
		if beaker:
			return
		print("beaker in")
		beaker_in = true
		beaker = body
		beaker.in_distill = true
		beaker.distill_pos = to_global($BeakerLoc.position)


func _on_pour_area_body_exited(body: Node2D) -> void:
	if body and body is Beaker and body == beaker:
		print("beaker out")
		beaker_in = false
		beaker.in_distill = false
		beaker = null
		


func _on_thermometer_area_mouse_entered() -> void:
	t_in = true
	if UI_communicator:
		UI_communicator.emit_signal("display_temperature", self, temperature)


func _on_thermometer_area_mouse_exited() -> void:
	t_in = false
	if UI_communicator:
		UI_communicator.emit_signal("stop_display", self)


func _on_rock_area_mouse_entered() -> void:
	rock_in = true


func _on_rock_area_mouse_exited() -> void:
	rock_in = false
