extends Node2D


var target: Vector2 = Vector2.ZERO

@export var  phase = 0
@export var  speed = 100
var scale_towards = 0.5 # influences moving towards target
var scale_oscilation = 0.5 # influences oscillating

@onready var collider: CollisionShape2D = $Collider
@onready var animated_sprite: AnimationPlayer = $AnimationPlayer

static var pop_scene = load("res://objects/bubble/bubble_pop/bubble_pop.tscn")


func _ready() -> void:
	name = "Bubble"+str(randi_range(0,9999999))
	animated_sprite.play("spawn")
	speed *= randf_range(0.7, 2.3)
	phase = randf_range(0, 2 * PI)


func set_target(new_target: Vector2) -> void:
	target = new_target


func _physics_process(delta: float) -> void:
	phase += delta
	var target_distance = target - global_position
	var normal_t = target_distance.normalized()
	var normal_p = Vector2(normal_t.y, -normal_t.x)
	# towards
	global_position += scale_towards * normal_t * speed * delta
	# perpendicular
	global_position += scale_oscilation * normal_p * sin(phase)
	if target_distance.length_squared() < 20 * 20:
		queue_free()


func _on_input_event(viewport:Node, event:InputEvent, shape_idx:int) -> void:
	var touch = event as InputEventScreenTouch
	if touch:
		spawn_pop()
		GAME_STATE.bubble_popped()
		queue_free()
		
func spawn_pop():
	var p = pop_scene.instantiate() as GPUParticles2D
	get_parent().add_child(p)
	p.global_position = global_position
	p.emitting = true
	p.finished.connect( func(): p.queue_free()) 
