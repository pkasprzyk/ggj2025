extends Node

# global singleton GAME_STATE

enum PlayerSide {
	PLAYER_LEFT,
	PLAYER_RIGHT,
}

enum BubbleType {
	SWORD,
	SHIELD,
	CANNON,
}

enum UnitType {
	SHOOTER,
	TANK,
	BAZOOKA,
}

const GAME_END_SCORE := 5000

var game_ended := false
var score: Array[int] = [0,0]
var timer := 0.0

var hud: Hud
var player_left_base: UnitBase
var player_right_base: UnitBase
var bullet_manager: Node

var autospawn_right_player: bool = true
var spawn_bubbles: bool
var right_spawn_timer: Timer

var bgm_player : AudioStreamPlayer

var in_replay_mode = false


static var replay_config : ReplayConfig = ReplayConfig.new()


func _ready() -> void:
	bgm_player = AudioStreamPlayer.new()
	bgm_player.name = "bgm_player"
	add_child(bgm_player)
	bgm_player.stream = load("res://bgm/reborn-battle-hybrid-cinematic-action-274988.mp3")
	bgm_player.play()


func init(
		i_hud : Hud,
		new_player_left_base: UnitBase,
		new_player_right_base: UnitBase,
		new_bullet_manager: Node
		) -> void:
	hud = i_hud
	var play_area = Rect2i(0, int(hud.size.y), 1920, 1080)
	player_left_base = new_player_left_base
	player_left_base.init(PlayerSide.PLAYER_LEFT, play_area)
	player_right_base = new_player_right_base
	player_right_base.init(PlayerSide.PLAYER_RIGHT, play_area)
	player_left_base.set_other_base(player_right_base)
	player_right_base.set_other_base(player_left_base)
	bullet_manager = new_bullet_manager

	right_spawn_timer = Timer.new()
	right_spawn_timer.wait_time = 1.0
	right_spawn_timer.one_shot = true
	right_spawn_timer.name = "right_spawn_timer"
	get_tree().current_scene.add_child(right_spawn_timer)

	reset_values()
	if in_replay_mode:
		_run_replay()
	else:
		_clear_replay()


func _process(delta: float) -> void:
	if game_ended:
		return

	timer += delta
	if right_spawn_timer.is_stopped() and autospawn_right_player:
		right_spawn_timer.start()
		spawn_unit_for(PlayerSide.PLAYER_RIGHT, UnitType.SHOOTER, player_right_base.generate_spawn_target())

	if hud:
		hud.update_values(timer, score)


func _reload_scene():
	get_tree().paused = false
	get_tree().reload_current_scene()


func reset():
	in_replay_mode = false
	_reload_scene()


func view_replay():
	in_replay_mode = true
	_reload_scene()


func _run_replay():
	autospawn_right_player = false
	spawn_bubbles = false
	for entry in replay_config.spawn_history:
		var time = entry[0]
		var side = entry[1]
		var unit_type = entry[2]
		var spawn_target = entry[3]
		get_tree().create_timer(time).connect("timeout", func (): spawn_unit_for(side, unit_type, spawn_target))
	for entry in replay_config.click_history:
		var time = entry[0]
		var side = entry[1]
		get_tree().create_timer(time).connect("timeout", func (): increment_score(side, 1))

func _clear_replay():
	replay_config.clear()


func reset_values():
	timer = 0.0
	score = [0,0]
	game_ended = false
	spawn_bubbles = true


func bubble_to_unit(bubble_type: BubbleType) -> UnitType:
	match bubble_type:
		BubbleType.SWORD:
			return UnitType.SHOOTER
		BubbleType.SHIELD:
			return UnitType.TANK
		BubbleType.CANNON:
			return UnitType.BAZOOKA
	return UnitType.SHOOTER


func bubble_popped(bubble: Bubble) -> void:
	increment_score(bubble.side, 1)
	replay_config.click_history.append([timer, bubble.side, bubble.type, bubble.global_position])
	var spawn_target = player_left_base.generate_spawn_target() if bubble.side == PlayerSide.PLAYER_LEFT else player_right_base.generate_spawn_target()
	var bonus = BubbleBonus.spawn(bullet_manager, bubble, spawn_target)
	var unit_type = bubble_to_unit(bubble.type)
	var side = bubble.side
	bonus.on_bonus_granted.connect(func (): spawn_unit_for(side, unit_type, spawn_target))


func spawn_unit_for(side:PlayerSide, unit_type:UnitType, spawn_target: Vector2) -> void:
	replay_config.spawn_history.append([timer, side, unit_type, spawn_target])
	if side == PlayerSide.PLAYER_LEFT:
		player_left_base.spawn_unit(unit_type, spawn_target)
	else :
		player_right_base.spawn_unit(unit_type, spawn_target)


func unit_died(unit:UnitShooter) -> void:
	increment_score(1 - unit.player, 50)


func base_hit(base:UnitBase) -> void:
	increment_score(1 - base.player, 100)


func spawn_bullet(shooter:UnitShooter, position:Vector2, velocity:Vector2):
	Bullet.spawn( shooter.type, bullet_manager, position, velocity)


func increment_score(side: PlayerSide, value: int) -> void:
	score[side] += value
	
	if not game_ended and score[side] >= GAME_END_SCORE:
		hud.update_values(timer, score)
		game_ended = true
		hud.game_ended()
		get_tree().paused = true


func toggle_autospawn() -> void:
	autospawn_right_player = not autospawn_right_player


func get_player_color(side: PlayerSide) -> Color:
	return Color(1, 0, 0, 1) if side == PlayerSide.PLAYER_LEFT\
	  else Color(0, 0, 1, 1)
