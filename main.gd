extends Node2D
# Main Buttons and Labels
@onready var play_button = $Play
@onready var option_button = $Option
@onready var quit_button = $Quit
@onready var title_text = $TitleScreen
@onready var my_label = $Labels/Label
@onready var my_label2 = $Labels/Label2
@onready var credits_text = $CreditsText
@onready var press_enter_label = $PressEnterText
# Volume Slider Container 
@onready var option_label = $Option2/option_label
@onready var option_label2 = $Option2/option_label2
@onready var back_button = $BackBtn
@onready var volume_slider = $VolumeSlider

func _ready() -> void:
	AudioController.play_music()
	Utilities.saveGame()
	Utilities.loadGame()
	
	# Show main menu by default
	show_main_menu()

func _input(event: InputEvent) -> void:
	# Check for Enter/Return key press
	if event.is_action_pressed("ui_accept"):
		AudioController.select_sound()
		get_tree().change_scene_to_file("res://world.tscn")
	
	# Check for Escape/Cancel to go back from options
	if event.is_action_pressed("ui_cancel"):
		if volume_slider and volume_slider.visible:
			AudioController.select_sound()
			show_main_menu()

# === SHOW/HIDE FUNCTIONS ===
func hide_main_menu():
	# Hide main menu buttons
	play_button.hide()
	quit_button.hide()
	option_button.hide()
	
	# Hide main menu labels
	title_text.hide()
	my_label.hide()
	my_label2.hide()
	credits_text.hide()
	press_enter_label.hide()
	
	# Show volume slider container, labels, and back button
	option_label.show()
	option_label2.show()
	back_button.show()
	volume_slider.show()

func show_main_menu():
	# Show all main menu buttons
	play_button.show()
	option_button.show()
	quit_button.show()
	
	# Show main menu labels
	title_text.show()
	my_label.show()
	my_label2.show()
	credits_text.show()
	press_enter_label.show()
	
	# Hide volume slider container, labels, and back button
	option_label.hide()
	option_label2.hide()
	back_button.hide()
	volume_slider.hide()

# === BUTTON FUNCTIONS ===
func _on_quit_pressed() -> void:
	AudioController.select_sound()
	get_tree().quit()

func _on_play_pressed() -> void:
	AudioController.select_sound()
	get_tree().change_scene_to_file("res://world.tscn")

func _on_option_pressed() -> void:
	AudioController.select_sound()
	# Hide main menu and show volume slider
	hide_main_menu()

# Back button function (connect this to your back button)
func _on_back_btn_pressed() -> void:
	AudioController.select_sound()
	# Show main menu and hide volume slider
	show_main_menu()

func _on_play_mouse_entered() -> void:
	AudioController.hover_button()

func _on_option_mouse_entered() -> void:
	AudioController.hover_button()

func _on_quit_mouse_entered() -> void:
	AudioController.hover_button()

func _on_back_btn_mouse_entered() -> void:
	AudioController.hover_button()
