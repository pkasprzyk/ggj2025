extends Node


class_name UnitBase

@onready var units_group: Node = $UnitsGroup

var spawn_x: float
var spawn_y_start: float
var spawn_y_end: float
var target_x: float
var player_side: GAME_STATE.PlayerSide


var other_base: UnitBase


var unit_class_map: Dictionary = {
	GAME_STATE.UnitType.SHOOTER: load("res://objects/unit_shooter/unit_shooter.tscn"),
	GAME_STATE.UnitType.TANK: load("res://objects/unit_shooter/unit_tank.tscn"),
	GAME_STATE.UnitType.BAZOOKA: load("res://objects/unit_shooter/unit_shooter.tscn"),  # TODO: replace with bazooka
}


func _ready() -> void:
	pass # Replace with function body.


func init(new_player_side: GAME_STATE.PlayerSide, new_spawn_x: float, new_spawn_y_start: float, new_spawn_y_end: float, new_target_x: float) -> void:
	player_side = new_player_side
	spawn_x = new_spawn_x
	spawn_y_start = new_spawn_y_start
	spawn_y_end = new_spawn_y_end
	target_x = new_target_x


func set_other_base(new_other_base: UnitBase) -> void:
	other_base = new_other_base


func spawn_unit(unit_type: GAME_STATE.UnitType) -> void:
	var spawn_point = Vector2(spawn_x, randf_range(spawn_y_start, spawn_y_end))
	var unit_class = unit_class_map[unit_type] as UnitShooter
	unit_class.spawn(units_group, spawn_point, player_side, self, Vector2(target_x, spawn_point.y), other_base)


func get_units() -> Array:
	return units_group.get_children()
