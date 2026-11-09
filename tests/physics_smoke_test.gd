extends SceneTree

const REQUIRED_SCENES: Array[String] = [
	"res://menu.tscn",
	"res://new_load.tscn",
	"res://options_menu.tscn",
	"res://pause_menu.tscn",
	"res://Scene/player.tscn",
	"res://Scene/main.tscn"
]

const PHYSICS_FRAMES_TO_SIMULATE := 120

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_required_scenes()
	_check_music_asset()
	await _check_gameplay_physics()

	if failures.is_empty():
		print("LatchPoint smoke test passed: required scenes loaded and player landed on a platform.")
		quit(0)
		return

	for failure in failures:
		push_error(failure)

	push_error("LatchPoint smoke test failed with %d issue(s)." % failures.size())
	quit(1)


func _check_required_scenes() -> void:
	for scene_path in REQUIRED_SCENES:
		var packed_scene := load(scene_path) as PackedScene
		if packed_scene == null:
			failures.append("Could not load required scene: %s" % scene_path)
			continue

		var instance := packed_scene.instantiate()
		if instance == null:
			failures.append("Could not instantiate required scene: %s" % scene_path)
		else:
			instance.free()


func _check_music_asset() -> void:
	if not ResourceLoader.exists("res://Project_bullshit.mp3"):
		failures.append("Configured music file is missing: res://Project_bullshit.mp3")


func _check_gameplay_physics() -> void:
	var main_scene := load("res://Scene/main.tscn") as PackedScene
	if main_scene == null:
		failures.append("Gameplay scene is unavailable; floor collision test cannot run.")
		return

	var world := main_scene.instantiate()
	if world == null:
		failures.append("Gameplay scene could not be instantiated.")
		return

	root.add_child(world)
	await process_frame

	var player := world.get_node_or_null("Player") as CharacterBody2D
	if player == null:
		failures.append("Gameplay scene does not contain a CharacterBody2D named Player.")
		world.queue_free()
		return

	var player_shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if player_shape == null or player_shape.shape == null or player_shape.disabled:
		failures.append("Player collision shape is missing, empty or disabled.")

	var pause_menu := world.get_node_or_null("PauseMenu")
	if pause_menu == null:
		failures.append("Gameplay scene does not contain the integrated PauseMenu.")

	var static_bodies := world.find_children("*", "StaticBody2D", true, false)
	var valid_platform_shapes := 0
	for body_variant in static_bodies:
		var body := body_variant as StaticBody2D
		if body == null:
			continue
		var shape_node := body.get_node_or_null("CollisionShape2D") as CollisionShape2D
		if shape_node != null and shape_node.shape != null and not shape_node.disabled:
			valid_platform_shapes += 1

	if valid_platform_shapes == 0:
		failures.append("Gameplay scene has no enabled StaticBody2D collision shapes.")

	for frame_index in range(PHYSICS_FRAMES_TO_SIMULATE):
		await physics_frame

	if not player.is_on_floor():
		failures.append(
			"Player did not register a floor collision after %d physics frames." %
			PHYSICS_FRAMES_TO_SIMULATE
		)

	world.queue_free()
	await process_frame
