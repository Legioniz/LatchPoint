extends CheckButton


func _ready() -> void:
	button_pressed = get_window().mode == Window.MODE_FULLSCREEN


func _on_toggled(toggled_on: bool) -> void:
	get_window().mode = Window.MODE_FULLSCREEN if toggled_on else Window.MODE_WINDOWED
