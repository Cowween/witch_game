extends Node
class_name UICommunicator
signal display_request(sender:Node, item_name: String, el_comp: String, amounts: String)
signal stop_display(sender: Node)
signal display_temperature(sender:Node, temp: float)
# Called when the node enters the scene tree for the first time.
