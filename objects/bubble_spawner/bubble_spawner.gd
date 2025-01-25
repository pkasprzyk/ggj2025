@icon("res://icons/bubble.svg")
extends Node2D


@export var bubble: PackedScene
@export var max_bubbles: int = 10
@export var rush_powerup_chance: float = 0.05


@onready var spawn_area_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var target_1: Node2D = $Area2D/Target1
@onready var target_2: Node2D = $Area2D/Target2
@onready var target_3: Node2D = $Area2D/Target3

@onready var spawn_timer: Timer = $SpawnTimer

@export var rect_test : Rect2


var bubbles: int = 0

func _ready():
	GAME_STATE.bonus_activated.connect(clear_other_bonuses)


func _gen_random_pos():
	var shape = spawn_area_shape.shape
	rect_test = shape.get_rect()
	var spawn_start = spawn_area_shape.global_position + shape.get_rect().position
	var spawn_end = spawn_area_shape.global_position + shape.get_rect().end
	var x = randf_range(spawn_start.x, spawn_end.x)
	var y = randf_range(spawn_start.y, spawn_end.y)
	return Vector2(x, y)


func _spawn_bubble() -> void:
	var bubble_instance = bubble.instantiate() as Bubble
	bubble_instance.connect("tree_exiting", _on_bubble_destroyed)
	add_child(bubble_instance)

	bubbles += 1
	
	var target = [
		target_1,
		target_2,
		target_3,
	].pick_random()

	if GAME_STATE.should_spawn_powerup():
		var bonus_content = GAME_STATE.get_pending_powerup_content()
		bubble_instance.initialize_powerup(_gen_random_pos(), target.global_position, bonus_content)
		GAME_STATE.powerup_spawned()
		return

	# UNIT bubble:
	var bubble_content = [
		GAME_STATE.BubbleContent.SWORD,
		GAME_STATE.BubbleContent.SHIELD,
		GAME_STATE.BubbleContent.CANNON,
	].pick_random()
	var side = [
		GAME_STATE.PlayerSide.PLAYER_LEFT,
		GAME_STATE.PlayerSide.PLAYER_RIGHT,
	].pick_random()
	bubble_instance.initialize_unit(_gen_random_pos(), target.global_position, side, bubble_content)


func clear_other_bonuses(_a, _b):
	for c in get_children():
		var b = c as Bubble
		if b and b.type == GAME_STATE.BubbleType.RUSH_POWERUP:
			b.queue_free()


func _on_bubble_destroyed() -> void:
	bubbles -= 1


func _physics_process(_delta: float) -> void:
	if GAME_STATE.spawn_bubbles and spawn_timer.is_stopped() and bubbles < max_bubbles:
		_spawn_bubble()
		spawn_timer.start()
