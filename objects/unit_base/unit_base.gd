extends Node


class_name UnitBase

@onready var units_group: Node = $UnitsGroup

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
	var spawn_point = Vector2(spawn_x, randf_range(spawn_y_start, spawn_y_end))
	var unit_instance = UnitShooter.spawn(UnitShooter.PlayerSide.PLAYER_LEFT, self, Vector2(target_x, spawn_point.y))
	units_group.add_child(unit_instance)
	print("spawn_point", spawn_point)
	unit_instance.global_position = spawn_point


func get_units() -> Array:
	return units_group.get_children()
