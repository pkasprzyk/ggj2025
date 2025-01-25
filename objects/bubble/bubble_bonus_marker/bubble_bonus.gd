class_name BubbleBonus
extends Node2D

static var bonus_scene = load("res://objects/bubble/bubble_bonus_marker/bubble_bonus.tscn") as PackedScene


@onready var icon : Sprite2D = $IconBG/Icon
@onready var icon_bg : Sprite2D = $IconBG
@onready var trail_pfx : GPUParticles2D = $TrailPfx

var fired := false

signal on_bonus_granted()
var player : GAME_STATE.PlayerSide

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir := 1 if player == GAME_STATE.PlayerSide.PLAYER_LEFT else -1
	position.x -= delta * 900.0 * dir
	if not fired and (global_position.x < -100 or global_position.x > (1980+100)):
		on_bonus_granted.emit()
		fired = true
		trail_pfx.emitting = false
		get_tree().create_timer(0.5).timeout.connect(func (): queue_free())


static func spawn(parent:Node2D, bubble: Bubble) -> BubbleBonus:
	var b = bonus_scene.instantiate() as BubbleBonus
	parent.add_child(b)
	b.global_position = bubble.global_position
	b.player = bubble.side
	var c = GAME_STATE.get_player_color(b.player)
	b.trail_pfx.modulate = c
	b.icon.modulate = c
	b.icon.texture = Bubble.icons[bubble.type]
	b.icon_bg.texture = Bubble.icons[bubble.type]
	return b
