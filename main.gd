extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.emulate_touch_from_mouse = true
	GAME_STATE.init($HUD/ScoreLabel)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
