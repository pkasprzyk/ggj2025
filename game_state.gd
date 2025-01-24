extends Node


# global singleton GAME_STATE


@onready var score: int = 0
var timer := 1.5 * 60.0

var score_label: Label
var player_left_base: UnitBase
var player_right_base: UnitBase

var right_spawn_timer: Timer


func init(
	new_score_label: Label,
	new_player_left_base: UnitBase,
	new_player_right_base: UnitBase,
	new_right_spawn_timer: Timer,
	viewport_top: float, viewport_right: float,
	viewport_bottom: float,
	viewport_left: float
) -> void:
	score_label = new_score_label
	player_left_base = new_player_left_base
	player_left_base.init(viewport_left, viewport_top, viewport_bottom, viewport_right)
	player_right_base = new_player_right_base
	player_right_base.init(viewport_right, viewport_top, viewport_bottom, viewport_left)
	right_spawn_timer = new_right_spawn_timer


func _process(delta: float) -> void:
	if not score_label:
		return
	timer -= delta
	score_label.text = "Time %2d:%02d - Score: %s" % [int(timer) / 60, int(timer) % 60, score]
	if right_spawn_timer.is_stopped():
		right_spawn_timer.start()
		player_right_base.spawn_unit()

	if timer < 0.0:
		get_tree().paused = true
		score_label.text += "\n GAME OVER"


func bubble_popped() -> void:
	increment_score(1)
	player_left_base.spawn_unit()


func increment_score(value: int) -> void:
	score += value
