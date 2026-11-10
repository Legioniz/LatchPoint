extends SceneTree

const MAIN_MENU_PATH := "res://menu.tscn"
const FRAMES_TO_RUN := 120


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene := load(MAIN_MENU_PATH) as PackedScene
	if packed_scene == null:
		push_error("Could not load the configured LatchPoint main menu.")
		quit(1)
		return

	var main_menu := packed_scene.instantiate()
	if main_menu == null:
		push_error("Could not instantiate the LatchPoint main menu.")
		quit(1)
		return

	root.add_child(main_menu)
	await process_frame

	for button_name in ["StartButton", "OptionsButton", "QuitButton"]:
		if main_menu.get_node_or_null(button_name) == null:
			push_error("Main menu is missing required control: %s" % button_name)
			main_menu.queue_free()
			await process_frame
			await _shutdown_audio()
			quit(1)
			return

	for _frame_index in range(FRAMES_TO_RUN):
		await process_frame

	main_menu.queue_free()
	await process_frame
	await _shutdown_audio()

	print("LatchPoint boot test passed: main menu loaded, controls resolved and frame loop completed.")
	quit(0)


func _shutdown_audio() -> void:
	var audio_manager := root.get_node_or_null("Audio")
	if audio_manager != null and audio_manager.has_method("shutdown_audio"):
		audio_manager.call("shutdown_audio")

	await process_frame
	await process_frame
