extends Node


class_name UnitBase

@onready var units_group: Node = $UnitsGroup
@onready var sprite: Sprite2D = $Sprite2D

var spawn_x: float
var spawn_y_start: float
var spawn_y_end: float
var target_x: float
var player: GAME_STATE.PlayerSide

var other_base: UnitBase


func _ready() -> void:
	pass # Replace with function body.


func init(
		new_player: GAME_STATE.PlayerSide,
		play_area: Rect2i) -> void:
	player = new_player
	spawn_y_start = play_area.position.y
	spawn_y_end = play_area.end.y
	sprite.modulate = GAME_STATE.get_player_color(player)
	
	if new_player == GAME_STATE.PlayerSide.PLAYER_LEFT:
		spawn_x = play_area.position.x
		target_x = play_area.end.x
	else:
		spawn_x = play_area.end.x
		target_x = play_area.position.x

func get_velocity() -> Vector2:
	return Vector2.ZERO


func set_other_base(new_other_base: UnitBase) -> void:
	other_base = new_other_base


func handle_hit(_bullet: Bullet) -> void:
	GAME_STATE.base_hit(self)


func spawn_unit(unit_type: GAME_STATE.UnitType) -> void:
	var spawn_position = Vector2(spawn_x, randf_range(spawn_y_start, spawn_y_end))
	var destination = Vector2(target_x, spawn_position.y)
	UnitShooter.spawn(unit_type, units_group, spawn_position, player, self, destination, other_base)


func get_units() -> Array:
	return units_group.get_children() + [self]
