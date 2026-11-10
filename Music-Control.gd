extends HSlider

@export var audio_bus_name: String = "Music"

var audio_bus_id: int = -1
var audio_manager: Node


func _ready() -> void:
	audio_manager = get_node_or_null("/root/Audio")
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)

	if audio_bus_id == -1:
		editable = false
		push_warning("Music volume control could not find audio bus: %s" % audio_bus_name)
		return

	if audio_manager != null and audio_manager.has_method("get_bus_volume_linear"):
		value = float(audio_manager.call("get_bus_volume_linear", audio_bus_name))
	else:
		value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus_id))


func _on_value_changed(new_value: float) -> void:
	if audio_bus_id == -1:
		return

	if audio_manager != null and audio_manager.has_method("set_bus_volume_linear"):
		audio_manager.call("set_bus_volume_linear", audio_bus_name, new_value)
		return

	AudioServer.set_bus_volume_db(audio_bus_id, linear_to_db(maxf(new_value, 0.0001)))
	AudioServer.set_bus_mute(audio_bus_id, is_zero_approx(new_value))
