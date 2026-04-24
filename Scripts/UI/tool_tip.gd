extends PanelContainer

@onready var item_name := $ToolTip/Name
@onready var description := $ToolTip/Description
@onready var composition := $ToolTip/Composition

@export var mouse_offset := Vector2.ZERO

var can_display := false
var display_queued := false
var current_sender: Node = null
func set_item_name(text:String) -> void:
	item_name.text = text
	
func set_description(output: String) -> void:
	description.text = output.strip_edges()
	await get_tree().process_frame
	print(description.text)
func set_temp(temp:float) -> void:
	var output := "Temperature: %.2f" %(temp)
	description.text = output
	await get_tree().process_frame
func set_composition(output: String) -> void:
	composition.text = output.strip_edges()
	await get_tree().process_frame
	print(composition.text)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:

	hide()

func _process(delta: float) -> void:
	var target_pos = get_global_mouse_position() + mouse_offset
	
	# Get the boundaries of the game window
	var screen_size = get_viewport_rect().size
	
	# Clamp X: Don't let it go past 0 (left) or the screen width minus the tooltip's width (right)
	target_pos.x = clamp(target_pos.x, 0, screen_size.x - size.x)
	
	# Clamp Y: Don't let it go past 0 (top) or the screen height minus the tooltip's height (bottom)
	target_pos.y = clamp(target_pos.y, 0, screen_size.y - size.y)
	
	global_position = target_pos

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("enquire"):
		can_display = not can_display
		if display_queued:
			show()
			await get_tree().process_frame
			reset_size()




func _on_ui_communicator_display_request(sender: Node, item_name: Variant, el_comp: Variant, desc: Variant) -> void:
	current_sender = sender # Lock onto the new object
	if can_display:
		visible = true
	display_queued = true
	set_item_name(item_name)
	set_composition(el_comp)
	set_description(desc)
	await get_tree().process_frame
	reset_size()

func _on_ui_communicator_stop_display(sender: Node) -> void:
	# ONLY hide if the object telling us to stop is the one we are currently looking at
	if sender == current_sender:
		visible = false
		display_queued = false
		current_sender = null

func _on_ui_communicator_display_temperature(sender: Node, temp: float) -> void:
	current_sender = sender
	if can_display:
		visible = true
	set_item_name("Thermometer")
	set_temp(temp)
	set_composition("")
	await get_tree().process_frame
	reset_size()
