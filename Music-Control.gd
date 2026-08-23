extends HSlider

@export var audio_bus_name: String = "Music"

var audio_bus_id

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	value_changed.connect(_on_value_changed)
	
	if audio_bus_id != -1:
		var current_db = AudioServer.get_bus_volume_db(audio_bus_id)
		value = db_to_linear(current_db)
func _on_value_changed(value: float) -> void:
	
	if audio_bus_id == -1:
		print("Warning: Audio bus '" + audio_bus_name + "' was not found!")
		return
		
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)

func _on_settings_button_pressed() -> void:
	$SettingsMenu.show() 
