extends Node2D

func _ready() -> void:
	#var theme = preload("res://RETRO_SPACE/RETRO_SPACE.ttf")
	#get_tree().root.gui_theme = theme
	AudioController.play_music()
	Utilities.saveGame()
	Utilities.loadGame()

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://world.tscn")
