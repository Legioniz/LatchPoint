extends SceneTree

const VIEWPORT_SIZES := [
	Vector2i(320, 480),
	Vector2i(640, 360),
	Vector2i(1280, 720),
]

const MENU_CASES := [
	{
		"path": "res://menu.tscn",
		"controls": ["Label", "StartButton", "OptionsButton", "QuitButton"],
		"show_after_ready": false,
	},
	{
		"path": "res://new_load.tscn",
		"controls": ["New", "Load"],
		"show_after_ready": false,
	},
	{
		"path": "res://options_menu.tscn",
		"controls": ["Label", "Label2", "HSlider", "Resolution", "Button"],
		"show_after_ready": false,
	},
	{
		"path": "res://pause_menu.tscn",
		"controls": [
			"MenuItems/resume",
			"MenuItems/return to menu",
			"MenuItems/Exit",
		],
		"show_after_ready": true,
	},
]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var passed := true

	for viewport_size in VIEWPORT_SIZES:
		for menu_case in MENU_CASES:
			var test_viewport := SubViewport.new()
			test_viewport.size = viewport_size
			test_viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
			root.add_child(test_viewport)

			var packed_scene := load(menu_case["path"]) as PackedScene
			if packed_scene == null:
				push_error("Could not load menu for layout test: %s" % menu_case["path"])
				passed = false
				test_viewport.queue_free()
				await process_frame
				continue

			var menu := packed_scene.instantiate() as Control
			if menu == null:
				push_error("Could not instantiate menu for layout test: %s" % menu_case["path"])
				passed = false
				test_viewport.queue_free()
				await process_frame
				continue

			test_viewport.add_child(menu)
			await process_frame
			await process_frame
			if menu_case["show_after_ready"]:
				menu.show()
				await process_frame

			var viewport_rect := Rect2(Vector2.ZERO, Vector2(viewport_size.x, viewport_size.y))
			var previous_rects: Array[Rect2] = []
			for control_path in menu_case["controls"]:
				var control := menu.get_node_or_null(control_path) as Control
				if control == null:
					push_error(
						"Missing responsive-layout control %s in %s"
						% [control_path, menu_case["path"]]
					)
					passed = false
					continue

				var rect := control.get_global_rect()
				if rect.size.x <= 0.0 or rect.size.y <= 0.0:
					push_error(
						"Control %s has no layout size at %s"
						% [control_path, viewport_size]
					)
					passed = false
				elif (
					rect.position.x < -0.5
					or rect.position.y < -0.5
					or rect.end.x > viewport_rect.end.x + 0.5
					or rect.end.y > viewport_rect.end.y + 0.5
				):
					push_error(
						"Control %s exceeds %s viewport bounds: %s"
						% [control_path, viewport_size, rect]
					)
					passed = false

				for previous_rect in previous_rects:
					if rect.intersects(previous_rect):
						push_error(
							"Control %s overlaps another menu control at %s"
							% [control_path, viewport_size]
						)
						passed = false
						break
				previous_rects.append(rect)

			test_viewport.queue_free()
			await process_frame

	if passed:
		print(
			"LatchPoint menu layout test passed: all main, new/load, options and pause controls " +
			"fit without overlap at 320x480, 640x360 and 1280x720."
		)
		quit(0)
	else:
		quit(1)
