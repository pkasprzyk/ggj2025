extends Node2D

class_name UnitShooter


@export var player: GAME_STATE.PlayerSide
@export var hp: float = 100.0
@export var speed: float = 100.0
@export var separation_distance_squared: float = 50.0 ** 2
@export var shooting_distance: float = 500.0
@export var rotation_speed: float = 0.05  # radians per tick

var type : GAME_STATE.UnitType

var target: Vector2 = Vector2.ZERO
var base: UnitBase
var other_base: UnitBase
var velocity: Vector2 = Vector2.ZERO

static var unit_type_to_scene: Dictionary = {
	GAME_STATE.UnitType.SHOOTER: load("res://objects/unit_shooter/unit_shooter.tscn"),
	GAME_STATE.UnitType.TANK: load("res://objects/unit_shooter/unit_tank.tscn"),
	GAME_STATE.UnitType.BAZOOKA: load("res://objects/unit_shooter/unit_bazooka.tscn"),
}

@onready var shooting_timer: Timer = $ShootingTimer
@onready var sprite: Sprite2D = $Sprite2D
@onready var barrel_tip: Marker2D = $BarrelTip
@onready var animation_player: AnimationPlayer = $AnimationPlayer


static func spawn(
		unit_type: GAME_STATE.UnitType,
		parent: Node,
		spawn_position: Vector2,
		new_player: GAME_STATE.PlayerSide,
		new_base: UnitBase,
		new_target: Vector2,
		new_other_base: UnitBase) -> UnitShooter:

	var unit_scene = unit_type_to_scene[unit_type] as PackedScene
	print_debug("SPAWN %s %s %s"%[new_player, unit_type, unit_scene.resource_path])

	var unit = unit_scene.instantiate()
	unit.name = "Shooter"+str(randi_range(0,9999999))
	unit.type = unit_type
	unit.player = new_player
	parent.add_child(unit)

	unit.global_position = spawn_position
	unit.base = new_base
	unit.other_base = new_other_base
	unit.target = new_target
	unit.sprite.modulate = GAME_STATE.get_player_color(new_player)
	unit.look_at(unit.target)
	return unit

func get_velocity() -> Vector2:
	return velocity


func _cohesion_rule(all_units) -> Vector2:
	var perceived_centre: Vector2

	if all_units.size() == 1:
		return Vector2.ZERO
	
	for other_unit in all_units:
		if self != other_unit:
			perceived_centre = perceived_centre + position
	
	perceived_centre = perceived_centre / (all_units.size() - 1)

	return (perceived_centre - position) / 10


func _separation_rule(all_units) -> Vector2:
	var separation_vec: Vector2

	if all_units.size() == 1:
		return Vector2.ZERO
	
	for other_unit in all_units:
		if self != other_unit:
			if (other_unit.position - position).length_squared() < separation_distance_squared:
				separation_vec = separation_vec - (other_unit.position - position)
	
	return separation_vec


func _allignment_rule(all_units) -> Vector2:
	var perceived_velocity: Vector2

	if all_units.size() == 1:
		return Vector2.ZERO
	
	for other_unit in all_units:
		if self != other_unit:
			perceived_velocity = perceived_velocity + other_unit.get_velocity()
	
	perceived_velocity = perceived_velocity / (all_units.size() - 1)
	
	return (perceived_velocity - velocity) / 2


func find_closest_enemy(all_units):
	var closest_enemy: Node2D = null
	var closest_distance: float = 9999999

	for other_unit in all_units:
		if self != other_unit:
			var distance = (other_unit.global_position - global_position).length()
			if distance < closest_distance:
				closest_distance = distance
				closest_enemy = other_unit

	return [closest_enemy, closest_distance]


func _rotate_clamped(new_velocity: Vector2) -> Vector2:
	var angle = new_velocity.angle_to(velocity)
	if abs(angle) > rotation_speed:
		angle = angle - rotation_speed if angle > 0 else angle + rotation_speed
		new_velocity = new_velocity.rotated(angle)
	look_at(global_position + new_velocity)
	return new_velocity


func _come_closer(delta: float) -> void:
	var friendly_units = base.get_units()
	var enemy_units = other_base.get_units()
	var new_velocity = (target - global_position).normalized() * speed / 2
	var cohesion_vec: Vector2 = _cohesion_rule(friendly_units)
	var seperation_vec: Vector2 = _separation_rule(friendly_units + enemy_units)
	var allignment_vec: Vector2 = _allignment_rule(friendly_units)
	new_velocity = new_velocity + cohesion_vec + allignment_vec + seperation_vec
	new_velocity = _rotate_clamped(new_velocity)
	velocity = new_velocity.normalized() * speed
	global_position += velocity * delta


func _physics_process(delta: float) -> void:
	var closest = find_closest_enemy(other_base.get_units())
	var closest_enemy = closest[0]
	var distance = closest[1]
	if distance < shooting_distance:
		velocity = (closest_enemy.global_position - global_position).normalized() * speed
		velocity = _rotate_clamped(velocity)
		try_shoot()
	else:
		_come_closer(delta)


func handle_hit(bullet: Bullet) -> void:
	hp -= get_damage(type, bullet.type)
	if hp <= 0:
		GAME_STATE.unit_died(self)
		queue_free()


func try_shoot() -> void:
	if not shooting_timer.is_stopped():
		return
	animation_player.play("shoot")
	shooting_timer.start()
	GAME_STATE.spawn_bullet(self, barrel_tip.global_position, velocity)


func get_damage(unit_type : GAME_STATE.UnitType, bullet_type:GAME_STATE.UnitType) -> float:
	match [unit_type, bullet_type]:
		[GAME_STATE.UnitType.SHOOTER, GAME_STATE.UnitType.BAZOOKA]: return 50.0
		[GAME_STATE.UnitType.TANK, GAME_STATE.UnitType.SHOOTER]: return 50.0
		[GAME_STATE.UnitType.BAZOOKA, GAME_STATE.UnitType.TANK]: return 50.0
	return 100.0
