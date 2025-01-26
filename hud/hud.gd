class_name Hud
extends Control

@onready var score_label = $TopBarBG/ScoreLabel
@onready var debug_menu = $DebugMenu
@onready var game_end = $GameEnd
@onready var progress_bar_l := ($ProgressBarL as ProgressBar)
@onready var progress_bar_r := ($ProgressBarR as ProgressBar)
@onready var debug_auto_spawner_icon := $ProgressBarR/RSwordLabel/DebugAutoSpawnerIcon
@onready var unit_labels = [
	[
		$ProgressBarL/LSwordLabel, 
		$ProgressBarL/LShieldLabel,
		$ProgressBarL/LCannonLabel, 
	],
	[
		$ProgressBarR/RSwordLabel,
		$ProgressBarR/RShieldLabel, 
		$ProgressBarR/RCannonLabel, 
	]
]


func _ready() -> void:
	refresh_debug_toggles()


@warning_ignore("integer_division")
func update_values(timer : float, score: Array[float], units_counter: Array) -> void:
	score_label.text = ("[center]Time %2d:%02d"+\
			"\nScore: [color=red]%s[/color] - [color=blue]%s[/color][/center]") % \
			[int(timer) / 60, int(timer) % 60,\
			 int(score[0]), int(score[1])]
	var r = 1 - (score[0] / CONFIG.points_goal())
	var l = 1 - (score[1] / CONFIG.points_goal())
	progress_bar_l.value = l * 100
	progress_bar_r.value = r * 100
	
	for p in units_counter.size():
		for u in units_counter[p].size():
			unit_labels[p][u].text = str(units_counter[p][u])


func refresh_debug_toggles() -> void:
	$DebugMenu/AutoSpawnToggle.text = "Autospawn right player (%.2f): %s" % \
		[CONFIG.get_debug_right_spawner_cooldown(), CONFIG.get_debug_right_spawner_active()]
	$DebugMenu/DeterministictUnitSpawnToggle.text = "Deterministic unit spawn: %s" %  CONFIG.get_debug_deterministic_spawn()
	$DebugMenu/EpicModeToggle.text = "Epic mode(%d): %s" % \
		[CONFIG.get_debug_epic_mode_count(), CONFIG.get_debug_epic_mode_active()]
	debug_auto_spawner_icon.visible = CONFIG.get_debug_right_spawner_active()


func game_ended() -> void:
	game_end.show()


func _on_back_to_menu_button_pressed() -> void:
	GAME_STATE.back_to_menu()


func _on_reset_button_pressed() -> void:
	GAME_STATE.reset()


func _on_debug_menu_button_pressed() -> void:
	debug_menu.show()


func _on_close_debug_menu_pressed() -> void:
	debug_menu.hide()


func _on_toggle_autospawn_button_pressed() -> void:
	GAME_STATE.toggle_autospawn()
	refresh_debug_toggles()


func _on_view_replay_button_pressed() -> void:
	GAME_STATE.view_replay()


func _on_toggle_deterministic_unit_spawn_button_pressed() -> void:
	GAME_STATE.toggle_deterministic_unit_spawn()
	refresh_debug_toggles()


func _on_toggle_epic_mode_button_pressed() -> void:
	GAME_STATE.toggle_epic_mode()
	refresh_debug_toggles()
