extends Node


# global singleton GAME_STATE


@onready var score: int = 0
var timer := 1.5 * 60.0

var hud: Hud
var player_left_base: UnitBase
var player_right_base: UnitBase

var right_spawn_timer: Timer


func init(
	i_hud : Hud,
	new_player_left_base: UnitBase,
	new_player_right_base: UnitBase,
	new_right_spawn_timer: Timer,
	viewport_top: float, viewport_right: float,
	viewport_bottom: float,
	viewport_left: float
) -> void:
	hud = i_hud
	player_left_base = new_player_left_base
	player_left_base.init(viewport_left, viewport_top, viewport_bottom, viewport_right)
	player_right_base = new_player_right_base
	player_right_base.init(viewport_right, viewport_top, viewport_bottom, viewport_left)
	right_spawn_timer = new_right_spawn_timer
	player_left_base.set_other_base(player_right_base)
	player_right_base.set_other_base(player_left_base)


func _process(delta: float) -> void:
	timer -= delta
	if right_spawn_timer.is_stopped():
		right_spawn_timer.start()
		player_right_base.spawn_unit(UnitShooter.PlayerSide.PLAYER_RIGHT)

	if hud:
		hud.update_values(timer, score)

	if timer < 0.0:
		get_tree().paused = true
		if hud:
			hud.game_ended()


func bubble_popped() -> void:
	increment_score(1)
	player_left_base.spawn_unit(UnitShooter.PlayerSide.PLAYER_LEFT)


func increment_score(value: int) -> void:
	score += value
