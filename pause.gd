extends Control

@onready var resume_button: Button = $resume


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel") or event.is_echo():
		return

	var options_menu := get_tree().get_first_node_in_group("options_menu_group")
	if options_menu != null and options_menu.visible:
		return

	toggle_menu()
	get_viewport().set_input_as_handled()


func toggle_menu() -> void:
	var should_pause := not get_tree().paused
	get_tree().paused = should_pause
	visible = should_pause

	if should_pause:
		resume_button.grab_focus.call_deferred()
	else:
		_release_pause_focus()


func _release_pause_focus() -> void:
	var focused_control := get_viewport().gui_get_focus_owner()
	if focused_control != null and is_ancestor_of(focused_control):
		focused_control.release_focus()


func _on_resume_pressed() -> void:
	get_tree().paused = false
	hide()
	_release_pause_focus()
	get_viewport().set_input_as_handled()


func _on_return_to_menu_pressed() -> void:
	get_tree().paused = false
	var error := get_tree().change_scene_to_file("res://menu.tscn")
	if error != OK:
		push_error("Unable to return to the main menu. Scene load error: %s" % error)


func _on_exit_pressed() -> void:
	get_tree().paused = false
	get_tree().quit()
