extends Node2D


var target: Vector2 = Vector2.ZERO

@onready var collider: CollisionShape2D = $Collider


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func set_target(new_target: Vector2) -> void:
	target = new_target


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	pass


func _on_input_event(viewport:Node, event:InputEvent, shape_idx:int) -> void:
	var touch = event as InputEventScreenTouch
	if touch:
		queue_free()
