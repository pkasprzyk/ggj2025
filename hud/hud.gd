class_name Hud
extends Control

@onready var score_label = $ScoreLabel

func update_values(timer : float, score: int) -> void:
	score_label.text = "Time %2d:%02d - Score: %s" % \
			[int(timer) / 60, int(timer) % 60, score]

func game_ended() -> void:
	score_label.text += "\n GAME OVER"
