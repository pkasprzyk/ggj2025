class_name Hud
extends Control

@onready var score_label = $TopBarBG/TopBar/ScoreLabel
@onready var credits = $Credits
@onready var credits_rich_text = $Credits/CreditsText
static var credits_config : CreditsConfig = load("res://config/credits.tres")


func _ready() -> void:
	credits_rich_text.text = "GLOBAL GAME JAM 2025"
	credits_rich_text.text += "\n [color=green]CODE[/color]"
	credits_rich_text.text += "\n - PK"
	credits_rich_text.text += "\n - ZEPHYR"
	credits_rich_text.text += "\n [color=green]GRAPHICS[/color]"
	for url in credits_config.external_credits:
		credits_rich_text.text += "\n - [url=%s] %s [/url]" % [url, url]
	credits_rich_text.text += "\n [color=green]BGM[/color]"
	for url in credits_config.music:
		credits_rich_text.text += "\n - [url=%s] %s [/url]" % [url, url]
	credits_rich_text.text += "\n [color=green]SFX[/color]"
	for url in credits_config.sfx:
		credits_rich_text.text += "\n - [url=%s] %s [/url]" % [url, url]


func _on_credits_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(meta)


func update_values(timer : float, score: Array[int]) -> void:
	score_label.text = "Time %2d:%02d - Score: %s - %s" % \
			[int(timer) / 60, int(timer) % 60, score[0], score[1]]


func game_ended() -> void:
	score_label.text += "\n GAME OVER"


func _on_button_pressed() -> void:
	GAME_STATE.reset()


func _on_credits_button_pressed() -> void:
	credits.show()


func _on_close_credits_pressed() -> void:
	credits.hide()
