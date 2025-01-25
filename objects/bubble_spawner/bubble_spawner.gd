@icon("res://icons/bubble.svg")
extends Node2D



@export var bubble: PackedScene
@export var max_bubbles: int = 10


@onready var spawn_area_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var target_1: Node2D = $Area2D/Target1
@onready var target_2: Node2D = $Area2D/Target2
@onready var target_3: Node2D = $Area2D/Target3

@onready var spawn_timer: Timer = $SpawnTimer

@export var rect_test : Rect2


var bubbles: int = 0


func _gen_random_pos():
	var shape = spawn_area_shape.shape
	rect_test = shape.get_rect()
	var spawn_start = spawn_area_shape.global_position + shape.get_rect().position
	var spawn_end = spawn_area_shape.global_position + shape.get_rect().end
	var x = randf_range(spawn_start.x, spawn_end.x)
	var y = randf_range(spawn_start.y, spawn_end.y)
	return Vector2(x, y)


func _spawn_bubble() -> void:
	var bubble_instance = bubble.instantiate()
	var side = [
		GAME_STATE.PlayerSide.PLAYER_LEFT,
		GAME_STATE.PlayerSide.PLAYER_RIGHT,
	].pick_random()
	var bubble_type = [
		GAME_STATE.BubbleType.SWORD,
		GAME_STATE.BubbleType.SHIELD,
		GAME_STATE.BubbleType.CANNON,
	].pick_random()
	bubble_instance.connect("tree_exiting", _on_bubble_destroyed)
	add_child(bubble_instance)
	var target = [
		target_1,
		target_2,
		target_3,
	].pick_random()
	bubble_instance.initialize(_gen_random_pos(), target.global_position, side, bubble_type)
	bubbles += 1


func _on_bubble_destroyed() -> void:
	bubbles -= 1

func _physics_process(_delta: float) -> void:
	if GAME_STATE.spawn_bubbles and spawn_timer.is_stopped() and bubbles < max_bubbles:
		_spawn_bubble()
		spawn_timer.start()
