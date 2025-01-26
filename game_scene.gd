extends Node

var play: bool = false


@onready var power_up_icon: Sprite2D = $PowerUpOverlay/PowerUpIcon
@onready var power_up_animation: AnimationPlayer = $PowerUpOverlay/AnimationPlayer
@onready var hud = $HUDCanvasGroup/HUD
@onready var player_left_base = $PlayerBases/PlayerLeftBase
@onready var player_right_base = $PlayerBases/PlayerRightBase
@onready var bullet_manager = $BulletManager


func _ready() -> void:
	Input.emulate_touch_from_mouse = true
	_do_play()


func _do_play() -> void:
	GAME_STATE.game_started = true
	hud.show()
	GAME_STATE.init(
		hud,
		player_left_base,
		player_right_base,
		bullet_manager,
	)
	GAME_STATE.bonus_activated.connect(on_bonus_activated)


func on_bonus_activated(_t: GAME_STATE.BubbleType, c: GAME_STATE.BubbleContent):
	power_up_animation.play("power_up_activated")
	power_up_icon.texture = GAME_STATE.get_icon_for(c)
