extends Area2D

@onready var tim := $AnimatedSprite2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tim.frame = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node2D) -> void:
	$Crunchybite.play()
	tim.play("default")
	body.queue_free()
	await tim.animation_finished
	tim.frame = 0
