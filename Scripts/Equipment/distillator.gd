extends StaticBody2D

const OPERATIONS := preload("res://Res/operations.tres")
@export var initial_temp := 25.0
@export var temp_increment := 0.2
@export var boil_rate := 0.5
@export var wait_time := 0.2
@onready var timer := $Timer
@export var flask_pos := Vector2.ZERO
@export var volume_decrease := 0.01
@export var UI_communicator : UICommunicator
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


func set_started(value: bool) -> void:
	started = value
	if started:
		$SRock.frame = 0
		$URock.frame = 0
		timer.start()
		populate_extractable()
	else:
		$SRock.frame = 1
		$URock.frame = 1
		timer.stop()
		temp_extractable = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.wait_time = wait_time
	actual_increment = temp_increment
	$SRock.frame = 1
	$URock.frame = 1


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_action("l_click"):
		if event.is_pressed() and rock_in:
			if started:
				started = false
			else:
				started = true

func populate_extractable() -> void:
	flask.tally_effects()
	#print(flask.total_comp)
	for i in flask.total_comp:
		if flask.total_comp[i] > 0.0:
			temp_extractable[OPERATIONS.DISTIL_TEMPS[i]] = i
	for i in temp_extractable:
		temp_list.append(i)
	temp_list.sort()
	#print(temp_extractable)
	#print(temp_list)
	
func extract_element(element:String, quant : float) -> bool:

	var usable : Array[Solution]
	for i in flask.all_solution:
		var temp := OPERATIONS.get_element_amount(element, i.amounts)
		if temp > 0.0:
			usable.append(i)
	if usable.is_empty():
		return true
	for i in usable:
		i.decrease_element(element, quant)
	if beaker:
		beaker.change_volume(quant, false, {element: {"Elemental": 1.0}}, "Elixir")
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
		return
	if temperature >= temp_list[0]:
		actual_increment = 0.0
		print("Distill", temp_extractable[temp_list[0]])
		var is_finished := extract_element(temp_extractable[temp_list[0]], boil_rate)
		if is_finished:
			temp_list.pop_front()
	else:
		actual_increment = temp_increment

func _on_click_area_mouse_entered() -> void:
	mouse_in = true


func _on_click_area_mouse_exited() -> void:
	mouse_in = false


func _on_timer_timeout() -> void:
		
	distill()
	temperature += actual_increment
	decrease_vol()
	




func _on_pour_area_body_entered(body: Node2D) -> void:
	if body and body is Beaker:
		beaker_in = true
		beaker = body


func _on_pour_area_body_exited(body: Node2D) -> void:
	if body and body is Beaker:
		beaker_in = false
		beaker = null


func _on_thermometer_area_mouse_entered() -> void:
	if UI_communicator:
		UI_communicator.emit_signal("display_temperature", temperature)


func _on_thermometer_area_mouse_exited() -> void:
	if UI_communicator:
		UI_communicator.emit_signal("stop_display")


func _on_rock_area_mouse_entered() -> void:
	rock_in = true


func _on_rock_area_mouse_exited() -> void:
	rock_in = false
