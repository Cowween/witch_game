extends VBoxContainer

@onready var item_name := $Name
@onready var description := $Description
@onready var composition := $Composition
func set_item_name(text:String) -> void:
	item_name.text = text
	
func set_description(el_comp: Dictionary[String, float], amounts: Dictionary[String, Dictionary]) -> void:
	var majors : Dictionary[String, float]
	var output := "Major elements: "
	for i in el_comp:
		if el_comp[i] >0.25:
			majors[i] = el_comp[i]
			output += i + " "
	output += "\n"
	for element in amounts:
		for state in amounts[element]:
			output += element + " " + state + ": " + str(amounts[element][state]) + "\n"
	description.text = output
	
func set_composition(el_comp: Dictionary[String, float]) -> void:
	var output := "Composition: "
	for i in el_comp:
		output += i + ": " + str(el_comp[i]) + " "
	composition.text = output
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#visible = false
	pass

func _process(delta: float) -> void:
	position = get_global_mouse_position()


func _on_ui_communicator_display_request(item_name: Variant, el_comp: Variant, amounts: Variant) -> void:
	set_item_name(item_name)
	set_composition(el_comp)
	set_description(el_comp, amounts)
