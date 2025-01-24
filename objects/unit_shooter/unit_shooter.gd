extends Node


var target: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _physics_process(delta: float) -> void:
	pass


func set_target(new_target: Vector2) -> void:
	target = new_target

