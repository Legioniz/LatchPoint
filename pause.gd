extends Control

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		var options = get_tree().get_first_node_in_group("options_menu_group")
		if options and options.visible:
			return
		toggle_menu()
		get_viewport().set_input_as_handled() 

func toggle_menu() -> void:
	get_tree().paused = !get_tree().paused
	visible = get_tree().paused
	
	var focus = get_viewport().gui_get_focus_owner()
	if focus:
		focus.release_focus()
