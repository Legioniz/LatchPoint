extends CheckButton

func _on_toggled(_toggled_on: bool) -> void:
	if get_viewport().mode != Window.MODE_FULLSCREEN:
		get_viewport().mode = Window.MODE_FULLSCREEN
	else:
		get_viewport().mode = Window.MODE_MAXIMIZED
