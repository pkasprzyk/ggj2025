extends Node


func _ready() -> void:
	Input.emulate_touch_from_mouse = true
	GAME_STATE.init(
		$HUD,
		$PlayerBases/PlayerLeftBase,
		$PlayerBases/PlayerRightBase,
		$BulletManager,
	)
