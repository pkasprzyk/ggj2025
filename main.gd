extends Node

var bubble_scene = load("res://objects/bubble/bubble.tscn") as PackedScene 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.emulate_touch_from_mouse = true
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

