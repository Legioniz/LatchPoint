extends Button

func _pressed() -> void:
	
	get_tree().paused = false
	release_focus() 
	var parent_menu = get_parent()
	if parent_menu:
		parent_menu.hide()
	get_viewport().set_input_as_handled()
