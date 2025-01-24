extends Node


# global singleton GAME_STATE


@onready var score: int = 0
var timer := 1.5 * 60.0

var score_label: Label 
var player_base: PlayerBase


func init(new_score_label: Label, new_player_base: PlayerBase, viewport_top: float, viewport_right: float, viewport_bottom: float, viewport_left: float) -> void:
	score_label = new_score_label
	player_base = new_player_base
	player_base.init(viewport_left, viewport_top, viewport_bottom, viewport_right)


func _process(delta: float) -> void:
	timer -= delta
	score_label.text = "Time %2d:%02d - Score: %s" % [int(timer)/60, int(timer)%60, score]
	if timer < 0.0:
		get_tree().paused = true
		score_label.text += "\n GAME OVER"


func bubble_popped() -> void:
	increment_score(1)
	player_base.spawn_unit()



func increment_score(value: int) -> void:
	score += value
