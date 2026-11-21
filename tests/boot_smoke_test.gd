extends SceneTree

const MAIN_MENU_PATH := "res://menu.tscn"
const NEW_LOAD_MENU_PATH := "res://new_load.tscn"
const OPTIONS_MENU_PATH := "res://options_menu.tscn"
const PAUSE_MENU_PATH := "res://pause_menu.tscn"
const FRAMES_TO_RUN := 120
const SETTINGS_TEST_PATH := "user://latchpoint_settings_smoke_test.cfg"
const SETTINGS_TEST_FILE_NAME := "latchpoint_settings_smoke_test.cfg"
const AUDIO_SHUTDOWN_VERIFIER := preload("res://tests/audio_shutdown_verifier.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var packed_scene := load(MAIN_MENU_PATH) as PackedScene
	if packed_scene == null:
		push_error("Could not load the configured LatchPoint main menu.")
		await _shutdown_audio()
		quit(1)
		return

	var main_menu := packed_scene.instantiate() as Control
	if main_menu == null:
		push_error("Could not instantiate the configured LatchPoint main menu.")
		await _shutdown_audio()
		quit(1)
		return

	root.add_child(main_menu)
	await process_frame
	await process_frame

	var keyboard_focus_passed: bool = await _check_keyboard_focus(main_menu)
	if not keyboard_focus_passed:
		main_menu.queue_free()
		await process_frame
		await _shutdown_audio()
		quit(1)
		return

	for button_name in ["StartButton", "OptionsButton", "QuitButton"]:
		if main_menu.get_node_or_null(button_name) == null:
			push_error("Main menu is missing required control: %s" % button_name)
			main_menu.queue_free()
			await process_frame
			await _shutdown_audio()
			quit(1)
			return

	var settings_persistence_passed: bool = await _check_settings_persistence()
	if not settings_persistence_passed:
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
	var audio_shutdown_passed: bool = await _shutdown_audio()
	if not audio_shutdown_passed:
		quit(1)
		return

	print(
		"LatchPoint boot test passed: menu loaded, audio/display settings persisted, " +
		"windowed decorations restored and frame loop completed."
	)
	quit(0)


func _check_keyboard_focus(main_menu: Control) -> bool:
	var start_button := main_menu.get_node_or_null("StartButton") as Button
	var options_button := main_menu.get_node_or_null("OptionsButton") as Button
	var quit_button := main_menu.get_node_or_null("QuitButton") as Button
	if start_button == null or options_button == null or quit_button == null:
		push_error("Main menu focus test could not resolve its three buttons.")
		return false

	var passed := true
	if not _expect_focus(start_button, "main menu initial focus"):
		passed = false
	await _send_key(KEY_DOWN)
	if not _expect_focus(options_button, "main menu down navigation"):
		passed = false
	await _send_key(KEY_DOWN)
	if not _expect_focus(quit_button, "main menu second down navigation"):
		passed = false
	await _send_key(KEY_UP)
	if not _expect_focus(options_button, "main menu up navigation"):
		passed = false

	var new_load_scene := load(NEW_LOAD_MENU_PATH) as PackedScene
	if new_load_scene == null:
		push_error("New/load menu could not be loaded for focus testing.")
		return false
	var new_load_menu := new_load_scene.instantiate() as Control
	if new_load_menu == null:
		push_error("New/load menu could not be instantiated for focus testing.")
		return false
	root.add_child(new_load_menu)
	await process_frame
	await process_frame

	var new_button := new_load_menu.get_node_or_null("New") as Button
	var load_button := new_load_menu.get_node_or_null("Load") as Button
	if new_button == null or load_button == null:
		push_error("New/load menu focus test could not resolve both buttons.")
		passed = false
	elif not _expect_focus(new_button, "new/load initial focus"):
		passed = false
	if load_button == null or not load_button.disabled or load_button.focus_mode != Control.FOCUS_NONE:
		push_error("Unavailable Load Game control must remain disabled and outside keyboard focus.")
		passed = false
	await _send_key(KEY_DOWN)
	if load_button != null and root.gui_get_focus_owner() == load_button:
		push_error("Keyboard navigation focused the disabled Load Game control.")
		passed = false

	new_load_menu.queue_free()
	await process_frame
	start_button.grab_focus.call_deferred()
	await process_frame
	await process_frame

	var options_scene := load(OPTIONS_MENU_PATH) as PackedScene
	if options_scene == null:
		push_error("Options menu could not be loaded for focus testing.")
		return false
	var options_menu := options_scene.instantiate() as Control
	if options_menu == null:
		push_error("Options menu could not be instantiated for focus testing.")
		return false
	root.add_child(options_menu)
	await process_frame
	await process_frame

	var volume_slider := options_menu.get_node_or_null("HSlider") as HSlider
	var fullscreen_toggle := options_menu.get_node_or_null("Resolution") as CheckButton
	var return_button := options_menu.get_node_or_null("Button") as Button
	if volume_slider == null or fullscreen_toggle == null or return_button == null:
		push_error("Options menu focus test could not resolve all interactive controls.")
		passed = false
	else:
		if not _expect_focus(volume_slider, "options initial focus"):
			passed = false
		await _send_key(KEY_DOWN)
		if not _expect_focus(fullscreen_toggle, "options down navigation"):
			passed = false
		await _send_key(KEY_DOWN)
		if not _expect_focus(return_button, "options second down navigation"):
			passed = false
		await _send_key(KEY_UP)
		if not _expect_focus(fullscreen_toggle, "options up navigation"):
			passed = false

	options_menu.queue_free()
	await process_frame
	start_button.grab_focus.call_deferred()
	await process_frame
	await process_frame

	var pause_scene := load(PAUSE_MENU_PATH) as PackedScene
	if pause_scene == null:
		push_error("Pause menu could not be loaded for focus testing.")
		return false
	var pause_menu := pause_scene.instantiate() as Control
	if pause_menu == null:
		push_error("Pause menu could not be instantiated for focus testing.")
		return false
	root.add_child(pause_menu)
	await process_frame
	await _send_key(KEY_ESCAPE)

	var resume_button := pause_menu.get_node_or_null("resume") as Button
	var pause_return_button := pause_menu.get_node_or_null("return to menu") as Button
	var exit_button := pause_menu.get_node_or_null("Exit") as Button
	if not paused or not pause_menu.visible:
		push_error("Escape did not open the pause menu and pause the SceneTree.")
		passed = false
	if resume_button == null or pause_return_button == null or exit_button == null:
		push_error("Pause menu focus test could not resolve all three buttons.")
		passed = false
	else:
		if not _expect_focus(resume_button, "pause menu initial focus"):
			passed = false
		await _send_key(KEY_DOWN)
		if not _expect_focus(pause_return_button, "pause menu first down navigation"):
			passed = false
		await _send_key(KEY_DOWN)
		if not _expect_focus(exit_button, "pause menu second down navigation"):
			passed = false
		await _send_key(KEY_UP)
		if not _expect_focus(pause_return_button, "pause menu up navigation"):
			passed = false
		await _send_key(KEY_UP)
		if not _expect_focus(resume_button, "pause menu return navigation"):
			passed = false
		await _send_key(KEY_SPACE)

	if paused or pause_menu.visible:
		push_error("Activating the focused Resume button did not close and unpause the game.")
		passed = false
		paused = false
		pause_menu.hide()

	pause_menu.queue_free()
	await process_frame
	start_button.grab_focus.call_deferred()
	await process_frame
	await process_frame
	return passed


func _expect_focus(expected: Control, context: String) -> bool:
	var actual := root.gui_get_focus_owner()
	if actual == expected:
		return true

	var actual_path := "<none>"
	if actual != null:
		actual_path = str(actual.get_path())
	push_error(
		"Keyboard focus regression (%s): expected %s, got %s." %
		[context, str(expected.get_path()), actual_path]
	)
	return false


func _send_key(keycode: int) -> void:
	var press_event := InputEventKey.new()
	press_event.keycode = keycode
	press_event.pressed = true
	Input.parse_input_event(press_event)
	await process_frame

	var release_event := InputEventKey.new()
	release_event.keycode = keycode
	release_event.pressed = false
	Input.parse_input_event(release_event)
	await process_frame


func _check_settings_persistence() -> bool:
	var settings_script := load("res://Settings.gd") as Script
	if settings_script == null:
		push_error("Settings autoload script could not be loaded.")
		return false
	if not _remove_test_settings_file():
		return false

	var defaults := settings_script.new() as Node
	defaults.set("settings_file_path", SETTINGS_TEST_PATH)
	defaults.call("load_settings")
	if (
		not is_equal_approx(float(defaults.call("get_bus_volume_linear", "Music")), 1.0)
		or not is_equal_approx(float(defaults.call("get_bus_volume_linear", "SFX")), 1.0)
		or bool(defaults.call("get_fullscreen"))
	):
		push_error("Missing settings file did not fall back to safe defaults.")
		defaults.free()
		_remove_test_settings_file()
		return false

	defaults.call("set_bus_volume_linear", "Music", 0.42)
	defaults.call("set_fullscreen", true)
	var save_error := int(defaults.call("save_now"))
	if save_error != OK:
		push_error("Settings smoke test could not write its isolated ConfigFile.")
		defaults.free()
		_remove_test_settings_file()
		return false

	var reloaded := settings_script.new() as Node
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
		reloaded.free()
		defaults.free()
		_remove_test_settings_file()
		return false

	var invalid_settings := settings_script.new() as Node
	invalid_settings.set("settings_file_path", SETTINGS_TEST_PATH)
	invalid_settings.call("load_settings")
	var invalid_values_recovered := (
		is_equal_approx(float(invalid_settings.call("get_bus_volume_linear", "Music")), 1.0)
		and is_equal_approx(float(invalid_settings.call("get_bus_volume_linear", "Master")), 0.0)
		and not bool(invalid_settings.call("get_fullscreen"))
	)
	if not invalid_values_recovered:
		push_error("Invalid saved settings did not recover to validated defaults.")

	invalid_settings.free()
	reloaded.free()
	defaults.free()
	var cleanup_passed := _remove_test_settings_file()
	if not round_trip_passed or not invalid_values_recovered or not cleanup_passed:
		return false
	return await _check_debounced_save_flush_on_exit(settings_script)


func _check_debounced_save_flush_on_exit(settings_script: Script) -> bool:
	if not _remove_test_settings_file():
		return false

	var main_window := root
	var previous_window_mode: int = main_window.mode
	var previous_borderless: bool = main_window.borderless

	var pending_settings := settings_script.new() as Node
	pending_settings.set("settings_file_path", SETTINGS_TEST_PATH)
	root.add_child(pending_settings)
	pending_settings.call("set_bus_volume_linear", "Music", 0.28)

	var save_timer := pending_settings.get("_save_timer") as Timer
	var timer_is_pending := save_timer != null and not save_timer.is_stopped()
	var write_is_deferred := not FileAccess.file_exists(SETTINGS_TEST_PATH)

	# Freeing the in-tree node invokes the Settings exit-tree flush before reload.
	pending_settings.free()
	var exit_flush_created_file := FileAccess.file_exists(SETTINGS_TEST_PATH)

	var reloaded := settings_script.new() as Node
	reloaded.set("settings_file_path", SETTINGS_TEST_PATH)
	reloaded.call("load_settings")
	var exit_flush_preserved_value := is_equal_approx(
		float(reloaded.call("get_bus_volume_linear", "Music")),
		0.28
	)
	reloaded.free()

	main_window.mode = previous_window_mode
	main_window.borderless = previous_borderless
	var cleanup_passed := _remove_test_settings_file()

	if not timer_is_pending:
		push_error("Settings smoke test did not start the debounced save timer.")
	if not write_is_deferred:
		push_error("Settings smoke test wrote preferences before the debounce timer elapsed.")
	if not exit_flush_created_file:
		push_error("Settings autoload did not flush pending preferences when leaving the scene tree.")
	if not exit_flush_preserved_value:
		push_error("Settings exit-tree flush did not preserve the latest preference.")
	return (
		timer_is_pending
		and write_is_deferred
		and exit_flush_created_file
		and exit_flush_preserved_value
		and cleanup_passed
	)


func _check_audio_settings_integration() -> bool:
	var settings_manager := root.get_node_or_null("Settings")
	var audio_manager := root.get_node_or_null("Audio")
	var settings_script := load("res://Settings.gd") as Script
	if (
		settings_manager == null
		or audio_manager == null
		or settings_script == null
		or audio_manager.get("settings_manager") != settings_manager
		or not audio_manager.has_method("set_bus_volume_linear")
	):
		push_error("Audio and Settings autoloads are not integrated.")
		return false
	if not _remove_test_settings_file():
		return false

	var isolated_settings := settings_script.new() as Node
	isolated_settings.set("settings_file_path", SETTINGS_TEST_PATH)
	isolated_settings.call("load_settings")
	audio_manager.set("settings_manager", isolated_settings)

	var original_volume := float(audio_manager.call("get_bus_volume_linear", "Music"))
	var test_volume := 0.37
	if is_equal_approx(original_volume, test_volume):
		test_volume = 0.63

	audio_manager.call("set_bus_volume_linear", "Music", test_volume)
	var audio_volume := float(audio_manager.call("get_bus_volume_linear", "Music"))
	var saved_volume := float(isolated_settings.call("get_bus_volume_linear", "Music"))
	var synchronized := (
		is_equal_approx(audio_volume, test_volume)
		and is_equal_approx(saved_volume, test_volume)
	)

	audio_manager.call("set_bus_volume_linear", "Music", original_volume)
	audio_manager.set("settings_manager", settings_manager)
	isolated_settings.free()
	var cleanup_passed := _remove_test_settings_file()

	if not synchronized:
		push_error("Music bus changes were not synchronized with persistent settings.")
	return synchronized and cleanup_passed


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


func _shutdown_audio() -> bool:
	var verifier = AUDIO_SHUTDOWN_VERIFIER.new()
	var result: Dictionary = await verifier.shutdown_and_wait(
		self,
		root.get_node_or_null("Audio"),
		false,
		"Boot"
	)

	for failure in result["errors"]:
		push_error(String(failure))

	if not result["errors"].is_empty():
		return false

	print("Boot-test audio shutdown passed: %s" % String(result["diagnostic"]))
	return true
