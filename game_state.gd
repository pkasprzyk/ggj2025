extends Node


# global singleton GAME_STATE


@onready var score: int = 0

var score_label: Label 


func init(label: Label) -> void:
	print(label)
	score_label = label


func increment_score(value: int) -> void:
	score += value
	score_label.text = "%s" % score
