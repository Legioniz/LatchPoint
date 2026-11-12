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
const MOVEMENT_TEST_FLOOR_Y := 160.0
const MOVEMENT_TEST_FLOOR_WIDTH := 1200.0
const ACCELERATION_TEST_FRAMES := 5
const FRICTION_TEST_FRAMES := 3
const MOVEMENT_ASSERTION_TOLERANCE := 1.0
const AUDIO_MIX_WAIT_MAX_FRAMES := 120
const AUDIO_MIX_AGE_RESET_TOLERANCE := 0.001


class PhysicsFrameWaiter:
	extends Node

	signal completed

	var remaining_frames := 0

	func start(frame_count: int) -> void:
		remaining_frames = frame_count

	func _physics_process(_delta: float) -> void:
		if remaining_frames <= 0:
			return

		remaining_frames -= 1
		if remaining_frames == 0:
			completed.emit()


var failures: Array[String] = []


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_check_required_scenes()
	_check_music_asset()
	await _check_gameplay_physics()
	await _check_player_movement()
	await _check_solid_collision_directions()
	await _shutdown_audio_before_exit()

	if failures.is_empty():
		print(
			"LatchPoint tests passed: scenes loaded; player landed; movement regressions held; " +
			"platform collision layers matched the player mask; floor, wall and ceiling collisions held; " +
			"audio shutdown observed a completed mix cycle."
		)
		quit(0)
		return

	for failure in failures:
		push_error(failure)

	push_error("LatchPoint tests failed with %d issue(s)." % failures.size())
	quit(1)


func _shutdown_audio_before_exit() -> void:
	var audio_manager := root.get_node_or_null("Audio")
	if audio_manager == null or not audio_manager.has_method("shutdown_audio"):
		failures.append("Audio autoload is unavailable; playback shutdown cannot be verified.")
	else:
		var music_player := audio_manager.get("music_player") as AudioStreamPlayer
		if music_player == null:
			failures.append("Audio autoload did not create its background music player.")
		else:
			if not music_player.has_stream_playback():
				failures.append("Background music did not start; playback shutdown cannot be verified.")
			audio_manager.call("shutdown_audio")
			if music_player.is_playing() or music_player.has_stream_playback() or music_player.stream != null:
				failures.append("Audio shutdown left the music player active or holding its stream.")

	var audio_driver := AudioServer.get_driver_name()
	var mix_rate := AudioServer.get_mix_rate()
	var next_mix_seconds := AudioServer.get_time_to_next_mix()
	var frames_waited := await _wait_for_audio_mix_after_shutdown()
	if frames_waited < 0:
		failures.append(
			"AudioServer driver '%s' did not complete an observable mix cycle within %d process frames." %
			[audio_driver, AUDIO_MIX_WAIT_MAX_FRAMES]
		)
		return

	print(
		"Audio shutdown diagnostic passed: driver=%s, mix_rate=%.0f Hz, initial_next_mix=%.4fs, " +
		"observed_mix_after=%d process frames." %
		[audio_driver, mix_rate, next_mix_seconds, frames_waited]
	)

	# AudioServer removes stopped playback on its mix thread and defers list cleanup
	# to the main thread. Allow the main-thread update to process that deferred cleanup.
	await process_frame
	await process_frame


func _wait_for_audio_mix_after_shutdown() -> int:
	var previous_mix_age := AudioServer.get_time_since_last_mix()
	for frame_index in range(AUDIO_MIX_WAIT_MAX_FRAMES):
		await process_frame
		var current_mix_age := AudioServer.get_time_since_last_mix()
		if current_mix_age + AUDIO_MIX_AGE_RESET_TOLERANCE < previous_mix_age:
			return frame_index + 1
		previous_mix_age = current_mix_age

	return -1


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
		if shape_node == null or shape_node.shape == null or shape_node.disabled:
			continue

		valid_platform_shapes += 1
		if body.collision_layer <= 0:
			failures.append(
				"Platform '%s' has no collision layer; the player cannot detect it." % body.name
			)
		elif (player.collision_mask & body.collision_layer) == 0:
			failures.append(
				"Player collision mask (%d) does not include platform '%s' layer (%d)." %
				[player.collision_mask, body.name, body.collision_layer]
			)

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


func _check_player_movement() -> void:
	var player_scene := load("res://Scene/player.tscn") as PackedScene
	if player_scene == null:
		failures.append("Player scene is unavailable; movement regression checks cannot run.")
		return

	var required_actions: Array[String] = ["ui_left", "ui_right", "ui_accept"]
	var actions_available := true
	for action in required_actions:
		if not InputMap.has_action(action):
			failures.append("Player movement test requires Input Map action: %s" % action)
			actions_available = false

	var fixture := Node2D.new()
	fixture.name = "PlayerMovementTestFixture"
	root.add_child(fixture)

	var floor_body := StaticBody2D.new()
	floor_body.position = Vector2(0.0, MOVEMENT_TEST_FLOOR_Y)

	var floor_shape := CollisionShape2D.new()
	var floor_rectangle := RectangleShape2D.new()
	floor_rectangle.size = Vector2(MOVEMENT_TEST_FLOOR_WIDTH, 20.0)
	floor_shape.shape = floor_rectangle
	floor_body.add_child(floor_shape)
	fixture.add_child(floor_body)

	var player_instance := player_scene.instantiate()
	if player_instance == null:
		failures.append("Player scene could not be instantiated.")
		fixture.queue_free()
		await process_frame
		_release_test_inputs()
		return

	var player := player_instance as CharacterBody2D
	if player == null:
		failures.append("Player scene root is not a CharacterBody2D.")
		player_instance.free()
		fixture.queue_free()
		await process_frame
		_release_test_inputs()
		return

	player.position = Vector2.ZERO
	fixture.add_child(player)

	var physics_waiter := PhysicsFrameWaiter.new()
	physics_waiter.process_physics_priority = 100
	root.add_child(physics_waiter)
	_release_test_inputs()

	await process_frame
	await _wait_for_physics_frames(physics_waiter, PHYSICS_FRAMES_TO_SIMULATE)

	if not player.is_on_floor():
		failures.append("Player movement fixture did not establish a grounded starting state.")
	elif actions_available:
		await _check_horizontal_movement(player, physics_waiter)
		await _check_jump_behavior(player, physics_waiter)

	_release_test_inputs()
	physics_waiter.queue_free()
	fixture.queue_free()
	await process_frame


func _check_horizontal_movement(player: CharacterBody2D, waiter: PhysicsFrameWaiter) -> void:
	if (
		player.get("move_speed") == null
		or player.get("acceleration") == null
		or player.get("friction") == null
	):
		failures.append("Player controller is missing its exported movement tuning properties.")
		return

	var move_speed := float(player.get("move_speed"))
	var acceleration := float(player.get("acceleration"))
	var friction := float(player.get("friction"))
	if move_speed <= 0.0 or acceleration <= 0.0 or friction <= 0.0:
		failures.append("Player movement tuning values must be positive for this regression test.")
		return

	var ticks_per_second := _get_physics_ticks_per_second()
	var physics_delta := Engine.time_scale / float(ticks_per_second)
	Input.action_press("ui_right")
	await _wait_for_physics_frames(waiter, ACCELERATION_TEST_FRAMES)

	var expected_speed := minf(
		move_speed,
		acceleration * float(ACCELERATION_TEST_FRAMES) * physics_delta
	)
	_expect_approx(
		player.velocity.x,
		expected_speed,
		"Player horizontal acceleration did not match the configured rate."
	)

	var speed_after_acceleration := player.velocity.x
	Input.action_release("ui_right")
	await _wait_for_physics_frames(waiter, FRICTION_TEST_FRAMES)

	var expected_speed_after_friction := maxf(
		0.0,
		speed_after_acceleration -
		friction * float(FRICTION_TEST_FRAMES) * physics_delta
	)
	_expect_approx(
		player.velocity.x,
		expected_speed_after_friction,
		"Player horizontal friction did not reduce speed at the configured rate."
	)


func _check_jump_behavior(player: CharacterBody2D, waiter: PhysicsFrameWaiter) -> void:
	if player.get("jump_velocity") == null:
		failures.append("Player controller is missing its exported jump velocity.")
		return

	var jump_velocity := float(player.get("jump_velocity"))
	if jump_velocity >= 0.0:
		failures.append("Player jump velocity must be negative for an upward jump.")
		return

	if not player.is_on_floor():
		failures.append("Player must be grounded before the jump regression check.")
		return

	Input.action_press("ui_accept")
	await _wait_for_physics_frames(waiter, 1)
	_expect_approx(
		player.velocity.y,
		jump_velocity,
		"Grounded jump did not apply the configured vertical velocity."
	)

	Input.action_release("ui_accept")
	await _wait_for_physics_frames(waiter, 3)

	if player.velocity.y <= jump_velocity:
		failures.append("Gravity did not increase vertical velocity after the jump.")
	if player.is_on_floor():
		failures.append("Player unexpectedly landed before the airborne jump rejection check.")
	else:
		Input.action_press("ui_accept")
		await _wait_for_physics_frames(waiter, 1)
		if player.velocity.y <= jump_velocity + MOVEMENT_ASSERTION_TOLERANCE:
			failures.append("Jump input reset vertical velocity while the player was airborne.")

	Input.action_release("ui_accept")


func _get_physics_ticks_per_second() -> int:
	return maxi(
		1,
		int(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60))
	)


func _wait_for_physics_frames(waiter: PhysicsFrameWaiter, frame_count: int) -> void:
	if frame_count <= 0:
		return

	waiter.start(frame_count)
	await waiter.completed


func _expect_approx(actual: float, expected: float, message: String) -> void:
	if absf(actual - expected) > MOVEMENT_ASSERTION_TOLERANCE:
		failures.append("%s Expected %.2f, got %.2f." % [message, expected, actual])


func _release_test_inputs() -> void:
	for action in ["ui_left", "ui_right", "ui_accept"]:
		if InputMap.has_action(action):
			Input.action_release(action)


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
