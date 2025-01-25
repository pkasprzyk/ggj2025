class_name Bubble
extends Node2D


var target: Vector2 = Vector2.ZERO

@export var  type: GAME_STATE.BubbleType
@export var  side: GAME_STATE.PlayerSide
@export var  contents: GAME_STATE.BubbleContent

var change_time : float

@export var  phase = 0
@export var  speed = 100
var scale_towards = 0.5 # influences moving towards target
var scale_oscilation = 1 # influences oscillating
var critical_target_distance: float = 20 # distance to target to destroy bubble

@onready var collider: CollisionShape2D = $Collider
@onready var animated_sprite: AnimationPlayer = $AnimationPlayer
@onready var icon_bg : Sprite2D = $IconBG
@onready var icon : Sprite2D = $IconBG/Icon


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
	change_time = CONFIG.change_bubble_types_period()


func _initialize_common(start_pos: Vector2, new_target: Vector2, new_type: GAME_STATE.BubbleType, new_contents: GAME_STATE.BubbleContent) -> void:
	type = new_type
	contents = new_contents
	global_position = start_pos
	target = new_target
	icon.texture = icons[contents]
	icon_bg.texture = icons[contents]


func initialize_unit(start_pos: Vector2, new_target: Vector2, new_side: GAME_STATE.PlayerSide, new_contents: GAME_STATE.BubbleContent) -> void:
	_initialize_common(start_pos, new_target, GAME_STATE.BubbleType.UNIT, new_contents)
	side = new_side
	icon.modulate = GAME_STATE.get_player_color(side)


func initialize_powerup(start_pos: Vector2, new_target: Vector2, new_contents: GAME_STATE.BubbleContent) -> void:
	_initialize_common(start_pos, new_target, GAME_STATE.BubbleType.RUSH_POWERUP, new_contents)
	icon.modulate = Color(1,1,0,1)


func _physics_process(delta: float) -> void:
	phase += delta
	var target_distance = target - global_position
	var normal_t = target_distance.normalized()
	var normal_p = Vector2(normal_t.y, -normal_t.x)
	# towards
	global_position += scale_towards * normal_t * speed * delta
	# perpendicular
	global_position += scale_oscilation * normal_p * sin(phase)
	if target_distance.length_squared() < critical_target_distance * critical_target_distance:
		if type ==  GAME_STATE.BubbleType.RUSH_POWERUP:
			GAME_STATE.powerup_bubble_lost()
		queue_free()
		return
	change_time -= delta
	if CONFIG.change_bubble_types_active() and \
			type == GAME_STATE.BubbleType.UNIT and change_time <= 0:
		change_time += CONFIG.change_bubble_types_period()
		contents += 1
		contents %= GAME_STATE.BubbleContent.CANNON + 1
		icon.texture = icons[contents]
		icon_bg.texture = icons[contents]


func _on_input_event(_viewport:Node, event:InputEvent, _shape_idx:int) -> void:
	var touch = event as InputEventScreenTouch
	if touch:
		spawn_pop()
		if type == GAME_STATE.BubbleType.UNIT:
			GAME_STATE.unit_bubble_popped(self)
			play_pop_cue()
		else:
			GAME_STATE.powerup_bubble_popped(self)
			play_boost_cue()
		queue_free()


func play_boost_cue():
	var powerup_sfx = load("res://objects/bubble/bubble_pop/power_up_grab-88510.mp3")
	play_cue(powerup_sfx)


func play_pop_cue():
	var sfx_res = [
		"res://objects/bubble/bubble_pop/bubble-pop-1.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-2.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-3.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-4.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-5.mp3",
		"res://objects/bubble/bubble_pop/bubble-pop-6.mp3"
	].pick_random()
	play_cue(load(sfx_res))


func play_cue(sfx):
	var audio_player = AudioStreamPlayer2D.new()
	audio_player.stream = sfx
	audio_player.volume_db = 30
	audio_player.connect("finished", audio_player.queue_free)
	get_tree().current_scene.add_child(audio_player)
	audio_player.global_position = global_position
	audio_player.play()


func spawn_pop():
	var p = pop_scene.instantiate() as GPUParticles2D
	get_parent().add_child(p)
	p.global_position = global_position
	p.emitting = true
	p.finished.connect( func(): p.queue_free()) 
