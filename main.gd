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

@onready var back_button = $BackBtn

# Volume Slider Container 
@onready var option_panel = $VolumeSlider
@onready var option = $VolumeSlider/Options

# Quit Panel Container
@onready var quit_panel = $ConfirmQuit

func _ready() -> void:
	AudioController.play_music()
	Utilities.saveGame()
	Utilities.loadGame()
	
	show_main_menu()
	option_panel.visible = false
	quit_panel.visible = false

func _input(event: InputEvent) -> void:
	# Check for Enter/Return key press
	if event.is_action_pressed("ui_accept"):
		if quit_panel and quit_panel.visible:
			AudioController.select_sound()
			get_tree().quit()
		else:
			AudioController.select_sound()
			get_tree().change_scene_to_file("res://world.tscn")
	
	# Check for Escape/Cancel to go back from options
	if event.is_action_pressed("ui_cancel"):
		if option_panel and option_panel.visible:
			AudioController.select_sound()
			show_main_menu()

# === SHOW/HIDE FUNCTIONS ===
func hide_main_menu():
	# Hide main menu buttons
	play_button.visible = false
	quit_button.visible = false
	option_button.visible = false
	
	# Hide main menu labels
	title_text.visible = false
	my_label.visible = false
	my_label2.visible = false
	credits_text.visible = false
	press_enter_label.visible = false
	
func show_main_menu():
	# Show all main menu buttons
	play_button.visible = true
	option_button.visible = true
	quit_button.visible = true
	
	# Show main menu labels
	title_text.visible = true
	my_label.visible = true
	my_label2.visible = true
	credits_text.visible = true
	press_enter_label.visible = true

# === BUTTON FUNCTIONS ===
func _on_quit_pressed() -> void:
	AudioController.select_sound()
	quit_panel.visible = true
	back_button.visible = false
	press_enter_label.visible = false
	play_button.visible = false
	option_button.visible = false
	quit_button.visible = false

func _on_play_pressed() -> void:
	AudioController.select_sound()
	get_tree().change_scene_to_file("res://world.tscn")

func _on_option_pressed() -> void:
	AudioController.select_sound()
	hide_main_menu()
	option_panel.visible = true
	back_button.visible = true

func _on_back_btn_pressed() -> void:
	AudioController.select_sound()
	show_main_menu()
	option_panel.visible = false
	back_button.visible = false

func _on_play_mouse_entered() -> void:
	AudioController.hover_button()

func _on_option_mouse_entered() -> void:
	AudioController.hover_button()

func _on_quit_mouse_entered() -> void:
	AudioController.hover_button()

func _on_back_btn_mouse_entered() -> void:
	AudioController.hover_button()

func _on_confirm_exit_pressed() -> void:
	get_tree().quit()
	
func _on_cancel_exit_pressed() -> void:
	AudioController.select_sound()
	show_main_menu()
	quit_panel.visible = false

func _on_confirm_exit_mouse_entered() -> void:
	AudioController.hover_button()
	
func _on_cancel_exit_mouse_entered() -> void:
	AudioController.hover_button()
