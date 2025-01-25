class_name Bubble
extends Node2D


var target: Vector2 = Vector2.ZERO

@export var  side: GAME_STATE.PlayerSide
@export var  type: GAME_STATE.BubbleType


@export var  phase = 0
@export var  speed = 100
var scale_towards = 0.5 # influences moving towards target
var scale_oscilation = 0.5 # influences oscillating

@onready var collider: CollisionShape2D = $Collider
@onready var animated_sprite: AnimationPlayer = $AnimationPlayer
@onready var icon_BG : Sprite2D = $Bubbles/IconBG
@onready var icon : Sprite2D = $Bubbles/IconBG/Icon


static var icon_shield = load("res://icons/IconGodotNode/node/icon_shield.png")
static var icon_sword = load("res://icons/IconGodotNode/node/icon_sword.png")
static var icon_cannon = load("res://icons/IconGodotNode/node/canon_2.png")

static var icons = [icon_sword, icon_shield, icon_cannon]


static var pop_scene = load("res://objects/bubble/bubble_pop/bubble_pop.tscn")


func _ready() -> void:
	name = "Bubble"+str(randi_range(0,9999999))
	animated_sprite.play("spawn")
	speed *= randf_range(0.7, 2.3)
	phase = randf_range(0, 2 * PI)


func initialize(start_pos: Vector2, new_target: Vector2, new_side : GAME_STATE.PlayerSide, new_type : GAME_STATE.BubbleType) -> void:
	side = new_side
	type = new_type
	global_position = start_pos
	target = new_target
	icon.texture = icons[type]
	icon_BG.texture = icons[type]
	var color = GAME_STATE.get_player_color(side)
	icon.modulate = color
	icon_BG.modulate = color


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
		GAME_STATE.bubble_popped(self)
		queue_free()
		play_pop_cue()


func play_pop_cue():
	var player = AudioStreamPlayer2D.new()
	var sfx_res = [
		"res://objects/bubble/bubble_pop/bubble-pop-1.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-2.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-3.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-4.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-5.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-6.mp3"
	].pick_random()
	player.stream = load(sfx_res)
	player.connect("finished", player.queue_free)
	get_tree().current_scene.add_child(player)
	player.global_position = global_position
	player.play()


func spawn_pop():
	var p = pop_scene.instantiate() as GPUParticles2D
	get_parent().add_child(p)
	p.global_position = global_position
	p.emitting = true
	p.finished.connect( func(): p.queue_free()) 
