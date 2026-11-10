extends Node

const SETTINGS_FILE_PATH := "user://settings.cfg"
const SAVE_DEBOUNCE_SECONDS := 0.5
const DEFAULT_BUS_VOLUMES := {
	"Master": 1.0,
	"Music": 1.0,
	"SFX": 1.0
}

# Public so the smoke test can use an isolated file without touching player settings.
var settings_file_path: String = SETTINGS_FILE_PATH

var _config := ConfigFile.new()
var _bus_volumes: Dictionary = DEFAULT_BUS_VOLUMES.duplicate()
var _fullscreen := false
var _dirty := false
var _save_timer: Timer


func _ready() -> void:
	_save_timer = Timer.new()
	_save_timer.one_shot = true
	_save_timer.wait_time = SAVE_DEBOUNCE_SECONDS
	_save_timer.timeout.connect(save_now)
	add_child(_save_timer)

	load_settings()
	_apply_display_settings()


func _exit_tree() -> void:
	save_now()


func load_settings() -> void:
	_config = ConfigFile.new()
	_bus_volumes = DEFAULT_BUS_VOLUMES.duplicate()
	_fullscreen = false
	_dirty = false

	var load_error := _config.load(settings_file_path)
	if load_error != OK:
		if load_error != ERR_FILE_NOT_FOUND:
			push_warning(
				"LatchPoint could not load settings (%s); using defaults." %
				error_string(load_error)
			)
		return

	for bus_name: String in DEFAULT_BUS_VOLUMES:
		var stored_value: Variant = _config.get_value(
			"audio",
			bus_name,
			DEFAULT_BUS_VOLUMES[bus_name]
		)
		if typeof(stored_value) != TYPE_INT and typeof(stored_value) != TYPE_FLOAT:
			continue

		var volume := float(stored_value)
		if is_finite(volume):
			_bus_volumes[bus_name] = clampf(volume, 0.0, 1.0)

	var fullscreen_value: Variant = _config.get_value("display", "fullscreen", false)
	if typeof(fullscreen_value) == TYPE_BOOL:
		_fullscreen = fullscreen_value


func get_bus_volume_linear(bus_name: String) -> float:
	return float(_bus_volumes.get(bus_name, 1.0))


func set_bus_volume_linear(bus_name: String, linear_value: float) -> void:
	if not _bus_volumes.has(bus_name):
		push_warning("LatchPoint settings do not define audio bus: %s" % bus_name)
		return
	if not is_finite(linear_value):
		push_warning("LatchPoint ignored a non-finite volume for bus: %s" % bus_name)
		return

	var normalized_value := clampf(linear_value, 0.0, 1.0)
	if is_equal_approx(float(_bus_volumes[bus_name]), normalized_value):
		return

	_bus_volumes[bus_name] = normalized_value
	_schedule_save()


func get_fullscreen() -> bool:
	return _fullscreen


func set_fullscreen(enabled: bool) -> void:
	var changed := _fullscreen != enabled
	_fullscreen = enabled
	_apply_display_settings()
	if changed:
		_schedule_save()


func save_now() -> Error:
	if not _dirty:
		return OK

	for bus_name: String in DEFAULT_BUS_VOLUMES:
		_config.set_value("audio", bus_name, _bus_volumes[bus_name])
	_config.set_value("display", "fullscreen", _fullscreen)

	var save_error := _config.save(settings_file_path)
	if save_error != OK:
		push_warning(
			"LatchPoint could not save settings (%s)." %
			error_string(save_error)
		)
		return save_error

	_dirty = false
	if is_instance_valid(_save_timer):
		_save_timer.stop()
	return OK


func _schedule_save() -> void:
	_dirty = true
	if is_instance_valid(_save_timer):
		_save_timer.start()
	else:
		save_now()


func _apply_display_settings() -> void:
	if not is_inside_tree():
		return

	var main_window := get_tree().root as Window
	if main_window == null:
		return

	main_window.mode = Window.MODE_FULLSCREEN if _fullscreen else Window.MODE_WINDOWED
	# Fullscreen forces borderless mode; windowed mode must restore decorations.
	main_window.borderless = _fullscreen
