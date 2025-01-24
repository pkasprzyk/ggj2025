extends Node


# global singleton GAME_STATE


@onready var score: int = 0
var timer := 1.5 * 60.0

var score_label: Label 


func init(label: Label) -> void:
	print(label)
	score_label = label

func _process(delta: float) -> void:
	timer -= delta
	score_label.text = "Time %2d:%02d - Score: %s" % [int(timer)/60, int(timer)%60, score]
	if timer < 0.0:
		get_tree().paused = true
		score_label.text += "\n GAME OVER"

func increment_score(value: int) -> void:
	score += value
