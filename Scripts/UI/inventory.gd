extends PanelContainer

var UI_communicator : UICommunicator : set = set_communicator
@onready var hbox := $IngredientsInventory/HBoxContainer
@export var cost : CostCounter

func set_communicator(value: UICommunicator) -> void:
	UI_communicator = value
	for i in hbox.get_children():
		i.UI_communicator = value

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in hbox.get_children():
		i.cost_counter = cost

func load_scenes_in_folder(path: String):
	var scenes = []
	var dir = DirAccess.open(path)
	
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				# Check for .tscn or .scn extensions
				if file_name.ends_with(".tscn") or file_name.ends_with(".scn"):
					var full_path = path + "/" + file_name
					var scene = load(full_path)
					scenes.append(scene)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access path: ", path)
		
	return scenes
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
