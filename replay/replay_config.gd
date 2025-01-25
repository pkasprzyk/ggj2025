class_name ReplayConfig
extends Resource

@export var spawn_history = []
@export var click_history = []


func clear():
	spawn_history.clear()
	click_history.clear()
