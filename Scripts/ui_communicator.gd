extends Node
class_name UICommunicator
signal display_request(item_name: String, el_comp: String, amounts: String)
signal stop_display
signal display_temperature(temp: float)
# Called when the node enters the scene tree for the first time.
