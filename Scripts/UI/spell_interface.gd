extends ColorRect
class_name SpellInterface
@onready var input := $LineEdit

signal spell_inputted(spell: String)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	input.text = ""
	visible = false

func begin_spell() -> void:
	visible = true

func _on_line_edit_text_submitted(new_text: String) -> void:
	input.text = ""
	visible = false
	spell_inputted.emit(new_text)
