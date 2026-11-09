extends Node

const MUSIC_TRACK_PATH := "res://Project_bullshit.mp3"

var volumes: Dictionary = {
	"Master": 1.0,
	"Music": 1.0,
	"SFX": 1.0
}

var music_player: AudioStreamPlayer


func _ready() -> void:
	get_tree().scene_changed.connect(_on_scene_changed)
	_apply_all_volumes()

	music_player = AudioStreamPlayer.new()
	music_player.name = "BackgroundMusic"
	music_player.bus = "Music"
	add_child(music_player)

	if ResourceLoader.exists(MUSIC_TRACK_PATH):
		var music_stream := load(MUSIC_TRACK_PATH) as AudioStream
		if music_stream != null:
			music_player.stream = music_stream
			music_player.play()
		else:
			push_warning("LatchPoint could not load the configured music stream.")
	else:
		push_warning("LatchPoint music file is missing: %s" % MUSIC_TRACK_PATH)


func _exit_tree() -> void:
	if is_instance_valid(music_player):
		music_player.stop()
		music_player.stream = null


func _on_scene_changed(_new_scene: Node) -> void:
	_apply_all_volumes()


func get_bus_volume_linear(bus_name: String) -> float:
	return clampf(float(volumes.get(bus_name, 1.0)), 0.0, 1.0)


func set_bus_volume_linear(bus_name: String, linear_value: float) -> void:
	var normalized_value := clampf(linear_value, 0.0, 1.0)
	volumes[bus_name] = normalized_value

	var bus_id := AudioServer.get_bus_index(bus_name)
	if bus_id == -1:
		push_warning("LatchPoint audio bus was not found: %s" % bus_name)
		return

	AudioServer.set_bus_volume_db(bus_id, linear_to_db(maxf(normalized_value, 0.0001)))
	AudioServer.set_bus_mute(bus_id, is_zero_approx(normalized_value))


func _apply_all_volumes() -> void:
	for bus_name: String in volumes:
		var bus_id := AudioServer.get_bus_index(bus_name)
		if bus_id == -1:
			continue

		var value := clampf(float(volumes[bus_name]), 0.0, 1.0)
		AudioServer.set_bus_volume_db(bus_id, linear_to_db(maxf(value, 0.0001)))
		AudioServer.set_bus_mute(bus_id, is_zero_approx(value))
