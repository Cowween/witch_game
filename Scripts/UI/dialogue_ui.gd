extends CanvasLayer
class_name DialogueUI
signal dialogue_over 
@export var speech_bubble_scene: PackedScene
@export var test_dialogue : DialogueResource
@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var vbox: VBoxContainer = $ScrollContainer/VBoxContainer

# 1. We create a custom signal to pause the dialogue manager
signal user_clicked

# 2. State tracking for the typewriter effect
var is_typing: bool = false
var current_tween: Tween
var current_label: RichTextLabel


func _ready() -> void:
	for i in vbox.get_children():
		i.queue_free()
	if test_dialogue:
		show_dialogue(test_dialogue)

func _input(event: InputEvent) -> void:
	# Listen for the exact moment the left mouse button is pressed down
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed():
		
		if is_typing:
			# STATE A: We are currently typing. Click = Skip typing.
			if current_tween and current_tween.is_valid():
				current_tween.kill()
			
			if current_label:
				current_label.visible_ratio = 1.0 # Force all text to show
				
			is_typing = false
			
		else:
			# STATE B: Text is fully visible. Click = Next dialogue line.
			user_clicked.emit()

func clear_dialogue() -> void:
	for i in vbox.get_children():
		i.queue_free()

func show_dialogue(resource: DialogueResource, encounter_state: Encounter = null, title: String = "start") -> void:
	var extra_states = []
	if encounter_state != null:
		extra_states.append(encounter_state)
	var line : DialogueLine= await DialogueManager.get_next_dialogue_line(resource, title, extra_states)
	
	while line != null:
		
		var bubble = speech_bubble_scene.instantiate()
		vbox.add_child(bubble)
		if line.character != "Witch":
			bubble.set_npc()
		
		current_label = bubble.label
		current_label.text = line.text
		
		
		# --- Typewriter Setup ---
		current_label.visible_ratio = 0
		is_typing = true
		
		current_tween = create_tween()
		current_tween.tween_property(current_label, "visible_ratio", 1.0, line.text.length() * 0.03)
		
		# If the tween finishes naturally (without being clicked), update our state
		current_tween.finished.connect(func(): is_typing = false)
		await get_tree().process_frame
		# Auto-scroll to the bottom as the bubble appears
		scroll_container.set_deferred("scroll_vertical", scroll_container.get_v_scroll_bar().max_value)
		
		# --- Wait Logic ---
		# 1. Wait for typing to finish (either naturally or skipped by _input)
		while is_typing:
			await get_tree().process_frame
			
		# 2. Wait for the NEXT user click to advance the dialogue

		await get_tree().create_timer(1.0).timeout
		line = await DialogueManager.get_next_dialogue_line(resource, line.next_id, extra_states)
	dialogue_over.emit()
