extends CanvasLayer
class_name  Book
@export var pages : Array[Texture2D]
@onready var book := $TextureRect

var page := 0 : set = set_page

func set_page(value: int) -> void:
	page = clamp(value, 0, pages.size()-1)
	
func open_book() -> void:
	show()
	page = 0
	book.texture = pages[page]
	
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_previous_pressed() -> void:
	page = page - 1
	book.texture = pages[page]


func _on_next_pressed() -> void:
	page = page+1
	book.texture = pages[page]
	print(page)


func _on_close_pressed() -> void:
	hide()
