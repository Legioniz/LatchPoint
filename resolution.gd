extends CheckButton


func _ready() -> void:
	var settings_manager := get_node_or_null("/root/Settings")
	if settings_manager != null and settings_manager.has_method("get_fullscreen"):
		button_pressed = bool(settings_manager.call("get_fullscreen"))
		# Reapply the stored preference in case the window state changed between scenes.
		settings_manager.call("set_fullscreen", button_pressed)
		return

	var window := get_window()
	button_pressed = window.mode == Window.MODE_FULLSCREEN
	_apply_fullscreen(button_pressed)


func _on_toggled(toggled_on: bool) -> void:
	var settings_manager := get_node_or_null("/root/Settings")
	if settings_manager != null and settings_manager.has_method("set_fullscreen"):
		settings_manager.call("set_fullscreen", toggled_on)
		return

	_apply_fullscreen(toggled_on)


func _apply_fullscreen(enabled: bool) -> void:
	var window := get_window()
	window.mode = Window.MODE_FULLSCREEN if enabled else Window.MODE_WINDOWED
	# Fullscreen forces borderless mode; restore native decorations in windowed mode.
	window.borderless = enabled
