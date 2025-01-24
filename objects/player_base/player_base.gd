extends Node


class_name PlayerBase


@export var unit: PackedScene

var spawn_x: float
var spawn_y_start: float
var spawn_y_end: float
var target_x: float


func _ready() -> void:
	pass # Replace with function body.


func init(new_spawn_x: float, new_spawn_y_start: float, new_spawn_y_end: float, new_target_x: float) -> void:
	spawn_x = new_spawn_x
	spawn_y_start = new_spawn_y_start
	spawn_y_end = new_spawn_y_end
	target_x = new_target_x


func spawn_unit() -> void:
	var unit_instance = unit.instantiate()
	add_child(unit_instance)
	var spawn_point = Vector2(spawn_x, randf_range(spawn_y_start, spawn_y_end))
	unit_instance.global_position = spawn_point
	unit_instance.set_target(Vector2(target_x, spawn_point.y))
