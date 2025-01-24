extends Node


func _ready() -> void:
	Input.emulate_touch_from_mouse = true
	GAME_STATE.init(
		$HUD/ScoreLabel,
		$PlayerLeftBase,
		$PlayerRightBase,
		$PlayerRightSpawnTimer,
		0, 1920, 1080, 0,
	)
