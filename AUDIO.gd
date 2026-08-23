extends Node

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
	add_child(music_player)

	music_player.bus = "Music" 

	music_player.stream = load("res://MUSIC/Project_bullshit.mp3")
	music_player.autoplay = true
	music_player.play()

func _on_scene_changed(_new_scene: Node) -> void:
	_apply_all_volumes()

func _apply_all_volumes() -> void:
	for bus_name in volumes:
		var bus_id = AudioServer.get_bus_index(bus_name)
		if bus_id != -1:
			var value = volumes[bus_name]
			var db = linear_to_db(value)
			AudioServer.set_bus_volume_db(bus_id, db)
			AudioServer.set_bus_mute(bus_id, value == 0.0)
