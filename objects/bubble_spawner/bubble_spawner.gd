extends Area2D


@export var bubble: PackedScene
@export var max_bubbles: int = 10


@onready var spawn_timer: Timer = $SpawnTimer
@onready var spawn_area: CollisionShape2D = $SpawnArea
@onready var target = $Target


var active: bool = true
var bubbles: int = 0
var spawn_start: Vector2
var spawn_end: Vector2

func _ready() -> void:
	spawn_start = spawn_area.shape.get_rect().position
	spawn_end = spawn_area.shape.get_rect().end


func _gen_random_pos():
	var x = randf_range(spawn_start.x, spawn_end.x)
	var y = randf_range(spawn_start.y, spawn_end.y)
	return Vector2(x, y)


func _spawn_bubble() -> void:
	var bubble_instance = bubble.instantiate()
	bubble_instance.global_position = _gen_random_pos()
	bubble_instance.set_target(target.global_position)
	bubble_instance.connect("tree_exiting", _on_bubble_destroyed)
	add_child(bubble_instance)
	bubbles += 1


func _on_bubble_destroyed() -> void:
	bubbles -= 1
	GAME_STATE.increment_score(1)


func _physics_process(delta: float) -> void:
	if spawn_timer.is_stopped() and active and bubbles < max_bubbles:
		_spawn_bubble()
		spawn_timer.start()
