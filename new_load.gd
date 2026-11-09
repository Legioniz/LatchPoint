extends Control

const GAME_SCENE_PATH := "res://Scene/main.tscn"


func _on_new_pressed() -> void:
	var error := get_tree().change_scene_to_file(GAME_SCENE_PATH)
	if error != OK:
		push_error("Unable to start LatchPoint. Scene load error: %s" % error)


func _on_load_pressed() -> void:
	push_warning("Load Game is not available yet. Save/load support has not been implemented.")
