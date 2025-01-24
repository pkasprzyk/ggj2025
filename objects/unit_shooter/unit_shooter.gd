extends Node2D

class_name UnitShooter

@export var speed: float = 100.0
@export var separation_distance: float = 50.0

var target: Vector2 = Vector2.ZERO
var base: UnitBase
var other_base: UnitBase
var velocity: Vector2 = Vector2.ZERO


enum PlayerSide {
	PLAYER_LEFT,
	PLAYER_RIGHT
}


static var unit_scene: PackedScene = load("res://objects/unit_shooter/unit_shooter.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


static func spawn(player: PlayerSide, new_base: UnitBase, new_target: Vector2, new_other_base: UnitBase) -> UnitShooter:
	var unit = unit_scene.instantiate()
	unit.base = new_base
	unit.other_base = new_other_base
	unit.target = new_target
	unit.modulate = Color(1, 0, 0, 1) if player == PlayerSide.PLAYER_LEFT else Color(0, 0, 1, 1)
	return unit


func _cohesion_rule(all_units) -> Vector2:
	var perceived_centre: Vector2

	if all_units.size() == 1:
		return Vector2.ZERO
	
	for other_unit in all_units:
		if self != other_unit:
			perceived_centre = perceived_centre + position
	
	perceived_centre = perceived_centre / (all_units.size() - 1)
	
	return (perceived_centre - position) / 10
	

func _seperation_rule(all_units) -> Vector2:
	var seperation_vec: Vector2

	if all_units.size() == 1:
		return Vector2.ZERO
	
	for other_unit in all_units:
		if self != other_unit:
			if (other_unit.position - position).length() < separation_distance:
				seperation_vec = seperation_vec - (other_unit.position - position)
	
	return seperation_vec
	
func _allignment_rule(all_units) -> Vector2:
	var perceived_velocity: Vector2

	if all_units.size() == 1:
		return Vector2.ZERO
	
	for other_unit in all_units:
		if self != other_unit:
			perceived_velocity = perceived_velocity + other_unit.velocity
	
	perceived_velocity = perceived_velocity / (all_units.size() - 1)
	
	return (perceived_velocity - velocity) / 2


func _physics_process(delta: float) -> void:
	var friendly_units = base.get_units()
	var enemy_units = other_base.get_units()
	var new_velocity = (target - global_position).normalized() * speed / 2
	var cohesion_vec: Vector2 = _cohesion_rule(friendly_units)
	var seperation_vec: Vector2 = _seperation_rule(friendly_units + enemy_units)
	var allignment_vec: Vector2 = _allignment_rule(friendly_units)
	new_velocity = new_velocity + cohesion_vec + allignment_vec + seperation_vec
	velocity = new_velocity.normalized() * speed
	look_at(global_position + velocity)
	global_position += velocity * delta
