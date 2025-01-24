extends Node2D


var target: Vector2 = Vector2.ZERO
var time = 0
var speed = 100
var t = 0.5 # influences moving towards target
var p = 0.5 # influences oscillating

@onready var collider: CollisionShape2D = $Collider
@onready var animated_sprite: AnimationPlayer = $AnimationPlayer

static var pop_scene = load("res://objects/bubble/bubble_pop/bubble_pop.tscn")


func _ready() -> void:
	animated_sprite.play("spawn")


func set_target(new_target: Vector2) -> void:
	target = new_target


func _physics_process(delta: float) -> void:
	time += delta
	var towards_target = (target - global_position).normalized()
	var perpendicular = Vector2(towards_target.y, -towards_target.x)
	global_position += (t * towards_target + p * perpendicular * sin(time)) * speed * delta


func _on_input_event(viewport:Node, event:InputEvent, shape_idx:int) -> void:
	var touch = event as InputEventScreenTouch
	if touch:
		spawn_pop()
		queue_free()
		
func spawn_pop():
	var p = pop_scene.instantiate() as GPUParticles2D
	get_parent().add_child(p)
	p.global_position = global_position
	p.emitting = true
	p.finished.connect( func(): p.queue_free()) 
