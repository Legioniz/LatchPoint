extends Control

@onready var play_button = $VBoxContainer/PlayButton
@onready var options_button = $VBoxContainer/OptionsButton
@onready var quit_button = $VBoxContainer/QuitButton

func _ready() -> void:
	play_button.pressed.connect(_on_play_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	print("Play clicked")
	# Get_tree().change_scene_to_file("res://game_scene.tscn")

func _on_options_pressed() -> void:
	print("Options clicked")

func _on_quit_pressed() -> void:
	get_tree().quit()
