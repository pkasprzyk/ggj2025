extends Node

# global singleton GAME_STATE

enum BubbleType {
	UNIT,
	RUSH_POWERUP,
}


enum PlayerSide {
	PLAYER_LEFT,
	PLAYER_RIGHT,
}

enum BubbleContent {
	SWORD,
	SHIELD,
	CANNON,
}

enum UnitType {
	SHOOTER,
	TANK,
	BAZOOKA,
}


var game_started := false
var game_ended := false
var in_replay_mode := false

var score: Array[float] = [0,0]
var timer := 0.0
var units_counter # Side -> type -> count

var hud: Hud
var player_left_base: UnitBase
var player_right_base: UnitBase
var bullet_manager: Node

var spawn_bubbles: bool
var right_spawn_timer: Timer
var epic_multiplier: int = 5

var bgm_player : AudioStreamPlayer

var power_up_count := 0
var power_up_pending_content := BubbleContent.SWORD
var power_up_cooldown_timestamp : float

static var replay_config : ReplayConfig = ReplayConfig.new()

static var icon_shield = load("res://icons/IconGodotNode/node/icon_shield.png")
static var icon_sword = load("res://icons/IconGodotNode/node/icon_sword.png")
static var icon_cannon = load("res://icons/IconGodotNode/node/canon_2.png")

static var icons = [icon_sword, icon_shield, icon_cannon]

signal bonus_activated(BubbleType, BubbleContent)

var replay_timers : Array[Timer] = [] 

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
	var play_area = Rect2i(0, int(hud.size.y) + 10, 1920, 1070)
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
	if game_started and CONFIG.get_debug_right_spawner_active() and \
			not in_replay_mode and right_spawn_timer.is_stopped() :
		right_spawn_timer.start(CONFIG.get_debug_right_spawner_cooldown())
		var side = PlayerSide.PLAYER_RIGHT
		var unit_type = UnitType.SHOOTER
		spawn_unit_for(side, unit_type, player_right_base.generate_spawn_target())
		# normally increments on bubble pop
		units_counter[side][unit_type] +=1

	if hud:
		hud.update_values(timer, score, units_counter)


func _reload_scene():
	get_tree().paused = false
	get_tree().reload_current_scene()


func reset():
	in_replay_mode = false
	clear_timers()
	_reload_scene()


func view_replay():
	in_replay_mode = true
	clear_timers()
	_reload_scene()


func back_to_menu():
	game_ended = true
	game_started = false
	in_replay_mode = false
	spawn_bubbles = false
	clear_timers()
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _run_replay():
	assert(in_replay_mode)
	spawn_bubbles = false
	clear_timers()
	
	for entry in replay_config.spawn_history:
		var time = entry[0]
		var side = entry[1]
		var unit_type = entry[2]
		var spawn_target = entry[3]
		var t = Timer.new()
		t.one_shot = true
		add_child(t)
		replay_timers.append(t)
		t.timeout.connect(spawn_unit_for.bind(side, unit_type, spawn_target))
		t.start(time)
	for entry in replay_config.click_history:
		var time = entry[0]
		var type = entry[1]
		var side = entry[2]
		var contents = entry[3]
		var _position = entry[4]
		var t = Timer.new()
		t.one_shot = true
		add_child(t)
		replay_timers.append(t)
		if type == BubbleType.UNIT:
			t.timeout.connect(increment_score.bind(side, CONFIG.points_per_spawn()))
			t.start(time)
		else:
			t.timeout.connect(process_bonus.bind(type, contents))
			t.start(time)


func clear_timers():
	for t in replay_timers:
		if t and not t.is_stopped:
			t.stop()
		t.queue_free()
	replay_timers = []


func _clear_replay():
	replay_config.clear()


func reset_values():
	timer = 0.0
	score = [0,0]
	game_ended = false
	spawn_bubbles = true
	units_counter = [
		[0,0,0],
		[0,0,0]
	]
	power_up_count = 0
	power_up_cooldown_timestamp = CONFIG.get_power_up_cooldown_s()


func bubble_to_unit(bubble_type: BubbleContent) -> UnitType:
	match bubble_type:
		BubbleContent.SWORD:
			return UnitType.SHOOTER
		BubbleContent.SHIELD:
			return UnitType.TANK
		BubbleContent.CANNON:
			return UnitType.BAZOOKA
	return UnitType.SHOOTER


func get_player_layer(player: PlayerSide) -> int:
	return 2 if player == PlayerSide.PLAYER_LEFT else 4  # this is flag!


func get_other_player(player: PlayerSide) -> PlayerSide:
	return PlayerSide.PLAYER_RIGHT if player == PlayerSide.PLAYER_LEFT else PlayerSide.PLAYER_LEFT


func unit_bubble_popped(bubble: Bubble) -> void:
	increment_score(bubble.side, CONFIG.points_per_spawn())
	replay_config.click_history.append([timer, bubble.type, bubble.side, bubble.contents, bubble.global_position])
	var spawn_target = player_left_base.generate_spawn_target() if bubble.side == PlayerSide.PLAYER_LEFT else player_right_base.generate_spawn_target()
	if CONFIG.get_debug_deterministic_spawn():
		spawn_target.y = bubble.global_position.y
	var bonus = BubbleBonus.spawn(bullet_manager, bubble, spawn_target)
	var unit_type = bubble_to_unit(bubble.contents)
	var side = bubble.side
	bonus.on_bonus_granted.connect(func (): spawn_unit_for(side, unit_type, spawn_target))
	units_counter[side][unit_type] += _get_spawned_units_amount()


func should_spawn_powerup() -> bool:
	return power_up_count < 2 && timer > power_up_cooldown_timestamp


func get_pending_powerup_content() -> BubbleContent:
	return power_up_pending_content


func powerup_spawned() -> void:
	power_up_pending_content = next_content(power_up_pending_content)
	power_up_count += 1

func powerup_bubble_lost():
	power_up_count -= 1

func powerup_bubble_popped(bubble: Bubble) -> void:
	replay_config.click_history.append([timer, bubble.type,  bubble.side, bubble.contents, bubble.global_position])
	process_bonus(bubble.type, bubble.contents)
	power_up_count = 0 # assumes bubble spawner destroys other powerups
	power_up_cooldown_timestamp = timer + CONFIG.get_power_up_cooldown_s()


func process_bonus(type: BubbleType, contents: BubbleContent) -> void:
	bonus_activated.emit(type, bubble_to_unit(contents))


func _get_spawned_units_amount() -> int:
	if CONFIG.get_debug_epic_mode_active():
		return CONFIG.get_debug_epic_mode_count()
	else:
		return 1


func spawn_unit_for(side:PlayerSide, unit_type:UnitType, spawn_target: Vector2) -> void:
	if not in_replay_mode:
		replay_config.spawn_history.append([timer, side, unit_type, spawn_target])
	var spawner: UnitBase
	if side == PlayerSide.PLAYER_LEFT:
		spawner = player_left_base
	else :
		spawner = player_right_base

	var units_to_spawn_count = _get_spawned_units_amount()
	for i in units_to_spawn_count:
		spawner.spawn_unit(unit_type, spawn_target)
		if in_replay_mode: # non-replay increments on bubble pop
			units_counter[side][unit_type] +=1


func unit_died(unit:UnitShooter) -> void:
	increment_score(1 - unit.player, CONFIG.points_per_kill())
	units_counter[unit.player][unit.type] -= 1


func base_hit(base:UnitBase) -> void:
	increment_score(1 - base.player, CONFIG.points_for_base_hit())


func spawn_bullet(shooter:UnitShooter, position:Vector2, velocity:Vector2):
	Bullet.spawn(shooter.type, bullet_manager, position, velocity, get_other_player(shooter.player))


func increment_score(side: PlayerSide, value: float) -> void:
	score[side] += value
	
	if not game_ended and score[side] >= CONFIG.points_goal():
		hud.update_values(timer, score, units_counter)
		game_ended = true
		hud.game_ended()
		get_tree().paused = true


func toggle_autospawn() -> void:
	CONFIG.toggle_debug_right_spawner_active()


func toggle_deterministic_unit_spawn() -> void:
	CONFIG.toggle_debug_deterministic_spawn()


func toggle_epic_mode() -> void:
	CONFIG.toggle_debug_epic_mode_active()


func get_player_color(side: PlayerSide) -> Color:
	return Color(1, 0, 0, 1) if side == PlayerSide.PLAYER_LEFT\
	  else Color(0, 0, 1, 1)

func get_icon_for(c:BubbleContent) -> Texture2D:
	return icons[c]

func next_content(c:BubbleContent) -> BubbleContent:
	return (int(c)+1) % 3 as BubbleContent
