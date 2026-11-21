extends Control

@onready var volume_slider: HSlider = $HSlider


func _ready() -> void:
	volume_slider.grab_focus.call_deferred()


func _on_button_pressed() -> void:
	var focused_node := get_viewport().gui_get_focus_owner()
	if focused_node != null:
		focused_node.release_focus()

	var error_code := get_tree().change_scene_to_file("res://menu.tscn")
	if error_code != OK:
		push_error("Unable to return to the main menu. Scene load error: %s" % error_code)
