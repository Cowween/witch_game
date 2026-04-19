extends HBoxContainer
@onready var label := $SpeechBubble/MarginContainer/RichTextLabel
@onready var bubble := $SpeechBubble
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_npc() -> void:
	bubble.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
