extends Area2D
class_name EncounterManager
signal encounter_over
@export var dialogue_ui : DialogueUI
@export var cost_counter : CostCounter
@export var end : End
@export var bell : Node2D


var encounters : Array[Encounter]
var curr_encounter :  Encounter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in get_children():
		if i is Encounter:
			encounters.append(i)
			i.bell = bell
			print("bell",bell)
			i.encounter_manager = self
			i.dialogue_ui = dialogue_ui
	curr_encounter = encounters.pop_front()

	if curr_encounter:
		curr_encounter.begin()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_encounter_over() -> void:
	curr_encounter.queue_free()
	if encounters.is_empty():
		end.show_end(cost_counter.total_cost, cost_counter.total_gain)
		return
	await get_tree().create_timer(randf_range(5,10)).timeout
	curr_encounter = encounters.pop_front()
	if curr_encounter:
		curr_encounter.begin()
	


func _on_body_entered(body: Node2D) -> void:
	if body is BottleOfPotion:
		print("checking potion")
		var check_res := curr_encounter.req_potion.check_potion(body.potion)
		if check_res == 7:
			cost_counter.total_gain+=curr_encounter.req_potion.reward
			curr_encounter.end()
			body.queue_free()
			await dialogue_ui.dialogue_over
			encounter_over.emit()
		else:
			curr_encounter.show_wrong(check_res)
