extends CheckButton


func _ready() -> void:
	var window := get_window()
	button_pressed = window.mode == Window.MODE_FULLSCREEN
	window.borderless = button_pressed


func _on_toggled(toggled_on: bool) -> void:
	var window := get_window()
	window.mode = Window.MODE_FULLSCREEN if toggled_on else Window.MODE_WINDOWED
	# Fullscreen forces borderless mode; restore native decorations in windowed mode.
	window.borderless = toggled_on
