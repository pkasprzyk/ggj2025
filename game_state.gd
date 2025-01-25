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

const MATCH_TIME = 0.5 * 60.0

@onready var score: int = 0
var timer := MATCH_TIME

var hud: Hud
var player_left_base: UnitBase
var player_right_base: UnitBase
var bullet_manager: Node

var right_spawn_timer: Timer


func init(
	i_hud : Hud,
	new_player_left_base: UnitBase,
	new_player_right_base: UnitBase,
	new_bullet_manager: Node,
	viewport_top: float, viewport_right: float,
	viewport_bottom: float,
	viewport_left: float
) -> void:
	hud = i_hud
	player_left_base = new_player_left_base
	player_left_base.init(viewport_left, viewport_top, viewport_bottom, viewport_right)
	player_right_base = new_player_right_base
	player_right_base.init(viewport_right, viewport_top, viewport_bottom, viewport_left)
	player_left_base.set_other_base(player_right_base)
	player_right_base.set_other_base(player_left_base)
	bullet_manager = new_bullet_manager
	
	right_spawn_timer = Timer.new()
	right_spawn_timer.wait_time = 1.0
	right_spawn_timer.one_shot = true
	right_spawn_timer.name = "right_spawn_timer"
	get_tree().current_scene.add_child(right_spawn_timer)


func _process(delta: float) -> void:
	timer -= delta
	if right_spawn_timer.is_stopped():
		right_spawn_timer.start()
		player_right_base.spawn_unit(PlayerSide.PLAYER_RIGHT)

	if hud:
		hud.update_values(timer, score)

	if timer < 0.0:
		get_tree().paused = true
		
		hud.game_ended()

func reset():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main.tscn")
	timer = MATCH_TIME


func bubble_popped() -> void:
	increment_score(1)
	player_left_base.spawn_unit(PlayerSide.PLAYER_LEFT)


func increment_score(value: int) -> void:
	score += value


func get_player_color(side: PlayerSide) -> Color:
	return Color(1, 0, 0, 1) if side == PlayerSide.PLAYER_LEFT\
	  else Color(0, 0, 1, 1)
