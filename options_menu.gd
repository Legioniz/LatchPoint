extends Control

func _on_button_pressed() -> void:
	var focused_node = get_viewport().gui_get_focus_owner()
	if focused_node:
		focused_node.release_focus()
	var error_code = get_tree().change_scene_to_file("res://menu.tscn")
	
