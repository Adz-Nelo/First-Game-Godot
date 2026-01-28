extends Node2D

func _ready() -> void:
	AudioController.play_music()
	Utilities.saveGame()
	Utilities.loadGame()

func _input(event: InputEvent) -> void:
	# Check for Enter/Return key press
	if event.is_action_pressed("ui_accept"):
		AudioController.select_sound()
		get_tree().change_scene_to_file("res://world.tscn")

func _on_quit_pressed() -> void:
	AudioController.select_sound()
	get_tree().quit()

func _on_play_pressed() -> void:
	AudioController.select_sound()
	get_tree().change_scene_to_file("res://world.tscn")

func _on_option_pressed() -> void:
	AudioController.select_sound()
	get_tree().change_scene_to_file("res://options.tscn")

func _on_play_mouse_entered() -> void:
	AudioController.hover_button()

func _on_option_mouse_entered() -> void:
	AudioController.hover_button()

func _on_quit_mouse_entered() -> void:
	AudioController.hover_button()
	
