extends SceneTree

const MAIN_MENU_PATH := "res://menu.tscn"
const FRAMES_TO_RUN := 120
const SETTINGS_TEST_PATH := "user://latchpoint_settings_smoke_test.cfg"
const SETTINGS_TEST_FILE_NAME := "latchpoint_settings_smoke_test.cfg"


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
		push_error("Could not instantiate the configured LatchPoint main menu.")
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

	if not _check_settings_persistence():
		main_menu.queue_free()
		await process_frame
		await _shutdown_audio()
		quit(1)
		return

	if not _check_audio_settings_integration():
		main_menu.queue_free()
		await process_frame
		await _shutdown_audio()
		quit(1)
		return

	var display_test_passed: bool = await _check_windowed_mode_restores_decorations()
	if not display_test_passed:
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

	print(
		"LatchPoint boot test passed: menu loaded, audio/display settings persisted, " +
		"windowed decorations restored and frame loop completed."
	)
	quit(0)


func _check_settings_persistence() -> bool:
	var settings_script := load("res://Settings.gd") as Script
	if settings_script == null:
		push_error("Settings autoload script could not be loaded.")
		return false
	if not _remove_test_settings_file():
		return false

	var defaults: Object = settings_script.new()
	defaults.set("settings_file_path", SETTINGS_TEST_PATH)
	defaults.call("load_settings")
	if (
		not is_equal_approx(float(defaults.call("get_bus_volume_linear", "Music")), 1.0)
		or not is_equal_approx(float(defaults.call("get_bus_volume_linear", "SFX")), 1.0)
		or bool(defaults.call("get_fullscreen"))
	):
		push_error("Missing settings file did not fall back to safe defaults.")
		_remove_test_settings_file()
		return false

	defaults.call("set_bus_volume_linear", "Music", 0.42)
	defaults.call("set_fullscreen", true)
	var save_error := int(defaults.call("save_now"))
	if save_error != OK:
		push_error("Settings smoke test could not write its isolated ConfigFile.")
		_remove_test_settings_file()
		return false

	var reloaded: Object = settings_script.new()
	reloaded.set("settings_file_path", SETTINGS_TEST_PATH)
	reloaded.call("load_settings")
	var round_trip_passed := (
		is_equal_approx(float(reloaded.call("get_bus_volume_linear", "Music")), 0.42)
		and bool(reloaded.call("get_fullscreen"))
	)
	if not round_trip_passed:
		push_error("Audio/display preferences did not survive a ConfigFile reload.")

	var invalid_config := ConfigFile.new()
	invalid_config.set_value("audio", "Music", "not-a-number")
	invalid_config.set_value("audio", "Master", -0.5)
	invalid_config.set_value("display", "fullscreen", "not-a-boolean")
	var invalid_save_error := invalid_config.save(SETTINGS_TEST_PATH)
	if invalid_save_error != OK:
		push_error("Settings smoke test could not write its invalid-value fixture.")
		_remove_test_settings_file()
		return false

	var invalid_settings: Object = settings_script.new()
	invalid_settings.set("settings_file_path", SETTINGS_TEST_PATH)
	invalid_settings.call("load_settings")
	var invalid_values_recovered := (
		is_equal_approx(float(invalid_settings.call("get_bus_volume_linear", "Music")), 1.0)
		and is_equal_approx(float(invalid_settings.call("get_bus_volume_linear", "Master")), 0.0)
		and not bool(invalid_settings.call("get_fullscreen"))
	)
	if not invalid_values_recovered:
		push_error("Invalid saved settings did not recover to validated defaults.")

	var cleanup_passed := _remove_test_settings_file()
	return round_trip_passed and invalid_values_recovered and cleanup_passed


func _check_audio_settings_integration() -> bool:
	var settings_manager := root.get_node_or_null("Settings")
	var audio_manager := root.get_node_or_null("Audio")
	if (
		settings_manager == null
		or audio_manager == null
		or not settings_manager.has_method("get_bus_volume_linear")
		or not audio_manager.has_method("set_bus_volume_linear")
	):
		push_error("Audio and Settings autoloads are not integrated.")
		return false

	var original_volume := float(audio_manager.call("get_bus_volume_linear", "Music"))
	var test_volume := 0.37
	if is_equal_approx(original_volume, test_volume):
		test_volume = 0.63

	audio_manager.call("set_bus_volume_linear", "Music", test_volume)
	var audio_volume := float(audio_manager.call("get_bus_volume_linear", "Music"))
	var saved_volume := float(settings_manager.call("get_bus_volume_linear", "Music"))
	var synchronized := (
		is_equal_approx(audio_volume, test_volume)
		and is_equal_approx(saved_volume, test_volume)
	)

	audio_manager.call("set_bus_volume_linear", "Music", original_volume)
	if not synchronized:
		push_error("Music bus changes were not synchronized with persistent settings.")
	return synchronized


func _remove_test_settings_file() -> bool:
	var user_directory := DirAccess.open("user://")
	if user_directory == null:
		push_error("Settings smoke test could not open the user data directory.")
		return false
	if not user_directory.file_exists(SETTINGS_TEST_FILE_NAME):
		return true

	var remove_error := user_directory.remove(SETTINGS_TEST_FILE_NAME)
	if remove_error != OK:
		push_error("Settings smoke test could not remove its temporary settings file.")
		return false
	return true


func _check_windowed_mode_restores_decorations() -> bool:
	var settings_manager := root.get_node_or_null("Settings")
	var previous_fullscreen := false
	if settings_manager != null and settings_manager.has_method("get_fullscreen"):
		previous_fullscreen = bool(settings_manager.call("get_fullscreen"))
		settings_manager.call("set_fullscreen", false)

	var main_window := root
	main_window.mode = Window.MODE_WINDOWED
	main_window.borderless = true

	var fullscreen_toggle := CheckButton.new()
	fullscreen_toggle.set_script(load("res://resolution.gd"))
	root.add_child(fullscreen_toggle)
	await process_frame

	var initialization_restored_decorations := not main_window.borderless
	main_window.borderless = true
	fullscreen_toggle.call("_on_toggled", false)
	var toggle_restored_decorations := not main_window.borderless

	fullscreen_toggle.queue_free()
	await process_frame

	if settings_manager != null and settings_manager.has_method("set_fullscreen"):
		settings_manager.call("set_fullscreen", previous_fullscreen)

	if not initialization_restored_decorations:
		push_error("Fullscreen toggle initialization did not restore window decorations in windowed mode.")
	if not toggle_restored_decorations:
		push_error("Leaving fullscreen did not restore the windowed borderless flag.")

	return initialization_restored_decorations and toggle_restored_decorations


func _shutdown_audio() -> void:
	var audio_manager := root.get_node_or_null("Audio")
	if audio_manager != null and audio_manager.has_method("shutdown_audio"):
		audio_manager.call("shutdown_audio")

	await process_frame
	await process_frame
