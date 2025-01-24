@icon("res://objects/bubble/bubbles.svg")
extends Node2D



@export var bubble: PackedScene
@export var max_bubbles: int = 10


@onready var spawn_timer: Timer = $SpawnTimer
@export var spawn_area_shape: CollisionShape2D
@export var target : Node2D

@export var rect_test : Rect2


var active: bool = true
var bubbles: int = 0


func _gen_random_pos():
	var shape = spawn_area_shape.shape
	rect_test = shape.get_rect()
	var spawn_start = spawn_area_shape.global_position + shape.get_rect().position
	var spawn_end = spawn_area_shape.global_position + shape.get_rect().end
	var x = randf_range(spawn_start.x, spawn_end.x)
	var y = randf_range(spawn_start.y, spawn_end.y)
	return Vector2(x, y)


func _spawn_bubble() -> void:
	var bubble_instance = bubble.instantiate()
	bubble_instance.set_target(target.global_position)
	bubble_instance.connect("tree_exiting", _on_bubble_destroyed)
	add_child(bubble_instance)
	bubble_instance.global_position = _gen_random_pos()
	bubbles += 1


func _on_bubble_destroyed() -> void:
	bubbles -= 1
	GAME_STATE.bubble_popped()


func _physics_process(delta: float) -> void:
	if spawn_timer.is_stopped() and active and bubbles < max_bubbles:
		_spawn_bubble()
		spawn_timer.start()
