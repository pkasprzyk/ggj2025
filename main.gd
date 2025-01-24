extends Node


func _ready() -> void:
	Input.emulate_touch_from_mouse = true
	var camera: Camera2D = $Camera2D
	GAME_STATE.init(
		$HUD/ScoreLabel,
		$PlayerBase,
		0, 1920, 1080, 0,
	)


func _process(delta: float) -> void:
	pass
