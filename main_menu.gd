extends Control


@onready var start_game_button: Button = $StartGameButton

@onready var credits = $Credits
@onready var credits_rich_text = $Credits/CreditsText

@onready var debug_menu = $DebugMenu

static var credits_config : CreditsConfig = load("res://config/credits.tres")
static var main_game_scene = preload('res://game_scene.tscn')


func _ready() -> void:
	generate_credits_text()
	refresh_debug_toggles()


func generate_credits_text():
	var text = "GLOBAL GAME JAM 2025"
	text += "\n [color=green]CODE[/color]"
	text += "\n - PK"
	text += "\n - ZEPHYR"
	text += "\n [color=green]GRAPHICS[/color]"
	for url in credits_config.external_credits:
		text += "\n - [url=%s] %s [/url]" % [url, url]
	text += "\n [color=green]BGM[/color]"
	for url in credits_config.music:
		text += "\n - [url=%s] %s [/url]" % [url, url]
	text += "\n [color=green]SFX[/color]"
	for url in credits_config.sfx:
		text += "\n - [url=%s] %s [/url]" % [url, url]

	credits_rich_text.text = text

func _on_credits_button_pressed() -> void:
	credits.show()


func _on_close_credits_pressed() -> void:
	credits.hide()


func _on_credits_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)


func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_packed(main_game_scene)
	
	
func _on_debug_menu_button_pressed() -> void:
	debug_menu.show()


func _on_close_debug_menu_pressed() -> void:
	debug_menu.hide()


func _on_toggle_autospawn_button_pressed() -> void:
	GAME_STATE.toggle_autospawn()
	refresh_debug_toggles()


func _on_toggle_deterministic_unit_spawn_button_pressed() -> void:
	GAME_STATE.toggle_deterministic_unit_spawn()
	refresh_debug_toggles()


func _on_toggle_epic_mode_button_pressed() -> void:
	GAME_STATE.toggle_epic_mode()
	refresh_debug_toggles()


func refresh_debug_toggles() -> void:
	$DebugMenu/AutoSpawnToggle.text = "Autospawn right player (%.2f): %s" % \
		[CONFIG.get_debug_right_spawner_cooldown(), CONFIG.get_debug_right_spawner_active()]
	$DebugMenu/DeterministictUnitSpawnToggle.text = "Deterministic unit spawn: %s" %  CONFIG.get_debug_deterministic_spawn()
	$DebugMenu/EpicModeToggle.text = "Epic mode(%d): %s" % \
		[CONFIG.get_debug_epic_mode_count(), CONFIG.get_debug_epic_mode_active()]
