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
const PROBE_FRAMES_TO_SIMULATE := 30
const PROBE_SIZE := Vector2(20.0, 20.0)

var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_required_scenes()
	_check_music_asset()
	await _check_gameplay_physics()
	await _check_solid_collision_directions()

	if failures.is_empty():
		print("LatchPoint tests passed: scenes loaded; player landed; floor, wall and ceiling collisions held.")
		quit(0)
		return

	for failure in failures:
		push_error(failure)

	push_error("LatchPoint tests failed with %d issue(s)." % failures.size())
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

	for _frame_index in range(PHYSICS_FRAMES_TO_SIMULATE):
		await physics_frame

	if not player.is_on_floor():
		failures.append(
			"Player did not register a floor collision after %d physics frames." %
			PHYSICS_FRAMES_TO_SIMULATE
		)

	world.queue_free()
	await process_frame


func _check_solid_collision_directions() -> void:
	await _check_collision_case(
		"floor",
		Vector2(0.0, 0.0),
		Vector2(0.0, 500.0),
		Vector2(0.0, 100.0),
		Vector2(200.0, 20.0)
	)
	await _check_collision_case(
		"wall",
		Vector2(0.0, 0.0),
		Vector2(500.0, 0.0),
		Vector2(100.0, 0.0),
		Vector2(20.0, 200.0)
	)
	await _check_collision_case(
		"ceiling",
		Vector2(0.0, 100.0),
		Vector2(0.0, -500.0),
		Vector2(0.0, 0.0),
		Vector2(200.0, 20.0)
	)


func _check_collision_case(
	collision_side: String,
	spawn_position: Vector2,
	commanded_velocity: Vector2,
	obstacle_position: Vector2,
	obstacle_size: Vector2
) -> void:
	var fixture := Node2D.new()
	root.add_child(fixture)

	var obstacle := StaticBody2D.new()
	obstacle.position = obstacle_position
	var obstacle_shape := CollisionShape2D.new()
	var obstacle_rectangle := RectangleShape2D.new()
	obstacle_rectangle.size = obstacle_size
	obstacle_shape.shape = obstacle_rectangle
	obstacle.add_child(obstacle_shape)
	fixture.add_child(obstacle)

	var probe_script := load("res://tests/physics_probe.gd") as Script
	if probe_script == null:
		failures.append("Physics probe script could not be loaded.")
		fixture.free()
		return

	var probe := CharacterBody2D.new()
	probe.set_script(probe_script)
	probe.position = spawn_position
	probe.set("commanded_velocity", commanded_velocity)

	var probe_shape := CollisionShape2D.new()
	var probe_rectangle := RectangleShape2D.new()
	probe_rectangle.size = PROBE_SIZE
	probe_shape.shape = probe_rectangle
	probe.add_child(probe_shape)
	fixture.add_child(probe)

	await process_frame
	for _frame_index in range(PROBE_FRAMES_TO_SIMULATE):
		await physics_frame

	var collision_detected := false
	var did_not_pass_through := false
	match collision_side:
		"floor":
			collision_detected = probe.is_on_floor()
			var floor_top := obstacle_position.y - obstacle_size.y * 0.5
			var player_bottom := probe.global_position.y + PROBE_SIZE.y * 0.5
			did_not_pass_through = player_bottom <= floor_top + 1.0
		"wall":
			collision_detected = probe.is_on_wall()
			var wall_left := obstacle_position.x - obstacle_size.x * 0.5
			var player_right := probe.global_position.x + PROBE_SIZE.x * 0.5
			did_not_pass_through = player_right <= wall_left + 1.0
		"ceiling":
			collision_detected = probe.is_on_ceiling()
			var ceiling_bottom := obstacle_position.y + obstacle_size.y * 0.5
			var player_top := probe.global_position.y - PROBE_SIZE.y * 0.5
			did_not_pass_through = player_top >= ceiling_bottom - 1.0

	if not collision_detected:
		failures.append("Physics probe did not register the expected %s collision." % collision_side)
	if not did_not_pass_through:
		failures.append("Physics probe passed through the %s collision surface." % collision_side)

	fixture.free()
	await process_frame
