extends Node


class_name UnitBase

@onready var units_group: Node = $UnitsGroup
@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D

var spawn_x: float
var spawn_y_start: float
var spawn_y_end: float
var target_x: float
var player: GAME_STATE.PlayerSide

var other_base: UnitBase

var rush_expiry_timer: Timer
var rush_time = 1.0

func _ready() -> void:
	GAME_STATE.connect("bonus_activated", activate_bonus)
	rush_expiry_timer = Timer.new()


func init(
		new_player: GAME_STATE.PlayerSide,
		play_area: Rect2i) -> void:
	player = new_player
	spawn_y_start = play_area.position.y
	spawn_y_end = play_area.end.y
	sprite.modulate = GAME_STATE.get_player_color(player)
	area.collision_layer = GAME_STATE.get_player_layer(player)
	
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


func generate_spawn_target() -> Vector2:
	return Vector2(spawn_x, randf_range(spawn_y_start, spawn_y_end))


func spawn_unit(unit_type: GAME_STATE.UnitType, spawn_target: Vector2) -> void:
	var destination = Vector2(target_x, spawn_target.y)
	UnitShooter.spawn(unit_type, units_group, spawn_target, player, self, destination, other_base)


func get_units() -> Array:
	return units_group.get_children() + [self]


func expire_bonus(type: GAME_STATE.BubbleType, unit_type: GAME_STATE.UnitType) -> void:
	for unit in get_units():
			if unit.type == unit_type:
				unit.speed /= 5


func activate_bonus(type: GAME_STATE.BubbleType, unit_type: GAME_STATE.UnitType) -> void:
	if type == GAME_STATE.BubbleType.RUSH_POWERUP:
		rush_expiry_timer.wait_time += rush_time
		rush_expiry_timer.connect("timeout", func(): self.expire_bonus(type, unit_type))
		if not rush_expiry_timer.is_stopped():
			# reset the timer, cannot update time left
			rush_expiry_timer.stop()
		rush_expiry_timer.start()

		for unit in get_units():
			if unit as UnitShooter and unit.type == unit_type:
				unit.speed *= 5
