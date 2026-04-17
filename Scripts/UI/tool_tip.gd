extends PanelContainer

@onready var item_name := $ToolTip/Name
@onready var description := $ToolTip/Description
@onready var composition := $ToolTip/Composition

@export var mouse_offset := Vector2.ZERO

@export var display_size := Vector2(92, 68)
var can_display := false
var display_queued := false
func set_item_name(text:String) -> void:
	item_name.text = text
	
func set_description(output: String) -> void:
	description.text = output
func set_temp(temp:float) -> void:
	var output := "Temperature: " + str(temp)
	description.text = output
func set_composition(output: String) -> void:
	composition.text = output
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	size = display_size

func _process(delta: float) -> void:
	position = get_global_mouse_position() + mouse_offset

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enquire"):
		can_display = true
		if display_queued:
			visible = true
	elif event.is_action_released("enquire"):
		can_display = false



func _on_ui_communicator_display_request(item_name: Variant, el_comp: Variant, desc: Variant) -> void:
	if can_display:
		visible = true
	display_queued = true
	set_item_name(item_name)
	set_composition(el_comp)
	set_description(desc)


func _on_ui_communicator_stop_display() -> void:
	visible = false
	display_queued = false


func _on_ui_communicator_display_temperature(temp: float) -> void:
	if can_display:
		visible = true
	set_item_name("Thermometer")
	set_temp(temp)
