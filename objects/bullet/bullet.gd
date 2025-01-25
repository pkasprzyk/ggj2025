extends Node2D

class_name Bullet

@export var speed: float = 500.0

static var bullet_scene: PackedScene = load("res://objects/bullet/bullet.tscn")
var direction: Vector2 = Vector2.ZERO
var type : GAME_STATE.UnitType

@onready var end_of_life_timer: Timer = $EndOfLifeTimer
@onready var area: Area2D = $Area2D

func _ready() -> void:
	$Area2D.monitoring = true


static func spawn(new_type:GAME_STATE.UnitType, parent: Node2D, new_position: Vector2, new_direction: Vector2, target_player: GAME_STATE.PlayerSide) -> Bullet:
	var bullet = bullet_scene.instantiate()
	parent.add_child(bullet)
	bullet.type = new_type
	bullet.global_position = new_position
	bullet.direction = new_direction.normalized()
	bullet.area.collision_mask = GAME_STATE.get_player_layer(target_player)
	bullet.look_at(bullet.global_position + new_direction)
	return bullet


func _physics_process(delta: float) -> void:
	if end_of_life_timer.is_stopped():
		queue_free()
		return
	global_position += direction * speed * delta
	if global_position.x < 0 or global_position.x > get_viewport_rect().size.x:
		queue_free()
		return


func _on_area_2d_area_entered(area: Area2D) -> void:
	var parent = area.get_parent()
	if parent.has_method("handle_hit"):
		parent.handle_hit(self)
		queue_free()
