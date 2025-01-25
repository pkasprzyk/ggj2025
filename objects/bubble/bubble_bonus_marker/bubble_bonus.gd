class_name BubbleBonus
extends Node2D

static var bonus_scene = load("res://objects/bubble/bubble_bonus_marker/bubble_bonus.tscn") as PackedScene


@onready var icon : Sprite2D = $IconBG/Icon
@onready var icon_bg : Sprite2D = $IconBG
@onready var trail_pfx : GPUParticles2D = $TrailPfx

@export var speed: float = 900
@export var minimal_distance_to_target: float = 10.0

var fired := false
var target: Vector2

signal on_bonus_granted()
var player : GAME_STATE.PlayerSide

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not fired and global_position.distance_to(target) < minimal_distance_to_target:
		on_bonus_granted.emit()
		fired = true
		trail_pfx.emitting = false
		get_tree().create_timer(0.5).timeout.connect(func (): queue_free())
		return
	
	global_position = global_position.move_toward(target, speed * delta)


static func spawn(parent:Node2D, bubble: Bubble, target: Vector2) -> BubbleBonus:
	var b = bonus_scene.instantiate() as BubbleBonus
	parent.add_child(b)
	b.global_position = bubble.global_position
	b.player = bubble.side
	var c = GAME_STATE.get_player_color(b.player)
	b.trail_pfx.modulate = c
	b.icon.modulate = c
	b.icon.texture = Bubble.icons[bubble.contents]
	b.icon_bg.texture = Bubble.icons[bubble.contents]
	b.target = target
	return b
