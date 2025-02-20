extends Node2D

class_name UnitShooter


@export var player: GAME_STATE.PlayerSide
@export var hp: float
@export var speed: float = 100.0
@export var separation_distance_squared: float = 50.0 ** 2
@export var shooting_distance: float = 500.0
@export var slowdown_while_shooting: float = 4.0
@export var minimum_shooting_distance: float = 300.0
@export var shooting_distance_variation: float = 200.0
@export var rotation_speed: float = 0.05  # radians per tick

var type : GAME_STATE.UnitType

var bonus_active:bool
var target: Vector2 = Vector2.ZERO
var base: UnitBase
var other_base: UnitBase
var velocity: Vector2 = Vector2.ZERO
var alive := true

static var unit_type_to_scene: Dictionary = {
	GAME_STATE.UnitType.SHOOTER: load("res://objects/unit_shooter/unit_shooter.tscn"),
	GAME_STATE.UnitType.TANK: load("res://objects/unit_shooter/unit_tank.tscn"),
	GAME_STATE.UnitType.BAZOOKA: load("res://objects/unit_shooter/unit_bazooka.tscn"),
}

@onready var shooting_cooldown: float
@onready var sprite: Sprite2D = $Sprite2D
@onready var barrel_tip: Marker2D = $BarrelTip
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var power_up_pfx: = $PowerUpPfx
@onready var splatter: GPUParticles2D = $Splatter
@onready var shooting_distance_offset: float = randf_range(0, shooting_distance_variation)


static func spawn(
		unit_type: GAME_STATE.UnitType,
		parent: Node,
		spawn_position: Vector2,
		new_player: GAME_STATE.PlayerSide,
		new_base: UnitBase,
		new_target: Vector2,
		new_other_base: UnitBase) -> UnitShooter:

	var unit_scene = unit_type_to_scene[unit_type] as PackedScene
	# print_debug("SPAWN %s %s %s"%[new_player, unit_type, unit_scene.resource_path])

	var unit = unit_scene.instantiate()
	unit.name = "Shooter"+str(randi_range(0,9999999))
	unit.type = unit_type
	unit.player = new_player
	unit.hp = CONFIG.unit_stats_hp()
	parent.add_child(unit)

	unit.global_position = spawn_position
	unit.base = new_base
	unit.other_base = new_other_base
	unit.target = new_target
	unit.sprite.modulate = GAME_STATE.get_player_color(new_player)
	unit.area.collision_layer = GAME_STATE.get_player_layer(new_player)
	unit.look_at(unit.target)
	return unit

func get_velocity() -> Vector2:
	return velocity

func set_bonus_active(active:bool) -> void:
	power_up_pfx.emitting = active
	bonus_active = active

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


func _come_closer(delta: float, slowdown: float = 1.0) -> void:
	var effective_speed = speed
	if bonus_active:
		effective_speed *= CONFIG.get_power_up_speed_mult()
	var friendly_units = base.get_units()
	var enemy_units = other_base.get_units()
	var new_velocity = (target - global_position).normalized() * effective_speed / 2
	var cohesion_vec: Vector2 = _cohesion_rule(friendly_units)
	var seperation_vec: Vector2 = _separation_rule(friendly_units + enemy_units)
	var allignment_vec: Vector2 = _allignment_rule(friendly_units)
	new_velocity = new_velocity + cohesion_vec + allignment_vec + seperation_vec
	new_velocity = _rotate_clamped(new_velocity)
	velocity = new_velocity.normalized() * effective_speed
	global_position += velocity * delta / slowdown


func _physics_process(delta: float) -> void:
	var time_dilatation = 1.0 if not bonus_active else CONFIG.get_power_up_shoot_mult()
	shooting_cooldown -= delta * time_dilatation
	var closest = find_closest_enemy(other_base.get_units())
	var closest_enemy = closest[0]
	var distance = closest[1]
	var slowdown := 1.0
	if distance < shooting_distance + shooting_distance_offset:
		velocity = (closest_enemy.global_position - global_position).normalized() * speed
		velocity = _rotate_clamped(velocity)
		try_shoot()
		slowdown = slowdown_while_shooting  # advance slower when shooting
	if distance > minimum_shooting_distance + shooting_distance_offset:
		_come_closer(delta, slowdown)


func handle_hit(bullet: Bullet) -> void:
	hp -= get_damage(type, bullet.type)
	if hp <= 0 and alive:
		alive = false
		collision_shape.set_deferred("disabled", true)
		GAME_STATE.unit_died(self)
		if splatter:
			splatter.connect("finished", queue_free)
			splatter.emitting = true		
		else:
			queue_free()
		

func try_shoot() -> void:
	if shooting_cooldown > 0 or not alive:
		return
	animation_player.play("shoot")
	shooting_cooldown = CONFIG.unit_stats_shoot_cooldown_s()
	GAME_STATE.spawn_bullet(self, barrel_tip.global_position, velocity)


func get_damage(unit_type : GAME_STATE.UnitType, bullet_type:GAME_STATE.UnitType) -> float:
	match [unit_type, bullet_type]:
		[GAME_STATE.UnitType.SHOOTER, GAME_STATE.UnitType.BAZOOKA]: 
			return CONFIG.unit_stats_reduced_damage()
		[GAME_STATE.UnitType.TANK, GAME_STATE.UnitType.SHOOTER]:
			return CONFIG.unit_stats_reduced_damage()
		[GAME_STATE.UnitType.BAZOOKA, GAME_STATE.UnitType.TANK]:
			return CONFIG.unit_stats_reduced_damage()
	return CONFIG.unit_stats_base_damage()
