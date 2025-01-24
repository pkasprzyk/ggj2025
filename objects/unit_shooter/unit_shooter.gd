extends Node2D

class_name UnitShooter

@export var speed: float = 100

var target: Vector2 = Vector2.ZERO
var base: UnitBase
var velocity: Vector2 = Vector2.ZERO


enum PlayerSide {
	PLAYER_LEFT,
	PLAYER_RIGHT
}


static var unit_scene: PackedScene = load("res://objects/unit_shooter/unit_shooter.tscn")


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


static func spawn(player: PlayerSide, new_base: UnitBase, new_target: Vector2) -> UnitShooter:
	var unit = unit_scene.instantiate()
	unit.base = new_base
	unit.target = new_target
	unit.modulate = Color(1, 0, 0, 1) if player == PlayerSide.PLAYER_LEFT else Color(0, 0, 1, 1)
	return unit


func _cohesion_rule(all_units) -> Vector2:
	var perceived_centre: Vector2
	
	for other_unit in all_units:
		if self != other_unit:
			perceived_centre = perceived_centre + position
	
	perceived_centre = perceived_centre / (all_units.size() - 1)
	
	return (perceived_centre - position) / 10
	

func _seperation_rule(all_units) -> Vector2:
	var seperation_vec: Vector2
	
	for other_unit in all_units:
		if self != other_unit:
			if (other_unit.position - position).length() < 150:
				seperation_vec = seperation_vec - (other_unit.position - position)
	
	return seperation_vec
	
func _allignment_rule(all_units) -> Vector2:
	var perceived_velocity: Vector2
	
	for other_unit in all_units:
		if self != other_unit:
			perceived_velocity = perceived_velocity + other_unit.velocity
	
	perceived_velocity = perceived_velocity / (all_units.size() - 1)
	
	return (perceived_velocity - velocity) / 2


func _physics_process(delta: float) -> void:
	var all_units = base.get_units()
	var new_velocity = (target - global_position).normalized() * speed / 2
	print(name, " new_vel", new_velocity, "pos", global_position, "target", target) 
	if all_units.size():
		var cohesion_vec: Vector2 = _cohesion_rule(all_units)
		var seperation_vec: Vector2 = _seperation_rule(all_units)
		var allignment_vec: Vector2 = _allignment_rule(all_units)
		new_velocity = new_velocity + cohesion_vec + allignment_vec + seperation_vec
	velocity = new_velocity.normalized() * speed
	look_at(velocity)
	global_position += velocity * delta
