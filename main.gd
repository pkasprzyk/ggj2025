extends Node

@onready var power_up_icon : Sprite2D = $PowerUpOverlay/PowerUpIcon
@onready var power_up_animation : AnimationPlayer = $PowerUpOverlay/AnimationPlayer

func _ready() -> void:
	Input.emulate_touch_from_mouse = true
	GAME_STATE.init(
		$HUDCanvasGroup/HUD,
		$PlayerBases/PlayerLeftBase,
		$PlayerBases/PlayerRightBase,
		$BulletManager,
	)
	GAME_STATE.bonus_activated.connect(on_bonus_activated)


func on_bonus_activated(t: GAME_STATE.BubbleType, c: GAME_STATE.BubbleContent):
	power_up_animation.play("power_up_activated")
	power_up_icon.texture = GAME_STATE.get_icon_for(c)
