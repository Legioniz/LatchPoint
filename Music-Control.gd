extends HSlider

@export var audio_bus_name: String = "Music"

var audio_bus_id: int = -1


func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	if audio_bus_id == -1:
		disabled = true
		push_warning("Music volume control could not find audio bus: %s" % audio_bus_name)
		return

	value = Audio.get_bus_volume_linear(audio_bus_name)


func _on_value_changed(new_value: float) -> void:
	if audio_bus_id == -1:
		return

	Audio.set_bus_volume_linear(audio_bus_name, new_value)
