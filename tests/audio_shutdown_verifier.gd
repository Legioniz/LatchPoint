extends RefCounted

const MAX_MIX_WAIT_FRAMES := 120
const MIX_AGE_RESET_TOLERANCE := 0.001
const DEFERRED_CLEANUP_FRAMES := 2


func shutdown_and_wait(
	tree: SceneTree,
	audio_manager: Node,
	require_active_playback: bool,
	context: String
) -> Dictionary:
	var errors: Array[String] = []
	if audio_manager == null or not audio_manager.has_method("shutdown_audio"):
		errors.append(
			"%s smoke test: Audio autoload is unavailable; playback shutdown cannot be verified." %
			context
		)
		return _build_result(errors)

	var music_player := audio_manager.get("music_player") as AudioStreamPlayer
	if music_player == null:
		errors.append(
			"%s smoke test: Audio autoload did not create its background music player." %
			context
		)
		return _build_result(errors)

	if require_active_playback and not music_player.has_stream_playback():
		errors.append(
			"%s smoke test: background music did not start; playback shutdown cannot be verified." %
			context
		)

	audio_manager.call("shutdown_audio")
	if music_player.is_playing() or music_player.has_stream_playback() or music_player.stream != null:
		errors.append(
			"%s smoke test: audio shutdown left the music player active or holding its stream." %
			context
		)

	var audio_driver := AudioServer.get_driver_name()
	var mix_rate := AudioServer.get_mix_rate()
	var next_mix_seconds := AudioServer.get_time_to_next_mix()
	var frames_waited := await _wait_for_audio_mix(tree)
	if frames_waited < 0:
		errors.append(
			"%s smoke test: AudioServer driver '%s' did not complete an observable mix cycle within %d process frames." %
			[context, audio_driver, MAX_MIX_WAIT_FRAMES]
		)
	else:
		for _frame_index in range(DEFERRED_CLEANUP_FRAMES):
			await tree.process_frame

	var diagnostic := ""
	if frames_waited >= 0:
		diagnostic = (
			"driver=%s, mix_rate=%.0f Hz, initial_next_mix=%.4fs, " +
			"observed_mix_after=%d process frames."
		) % [audio_driver, mix_rate, next_mix_seconds, frames_waited]

	return {
		"errors": errors,
		"frames_waited": frames_waited,
		"diagnostic": diagnostic
	}


func _wait_for_audio_mix(tree: SceneTree) -> int:
	var previous_mix_age := AudioServer.get_time_since_last_mix()
	for frame_index in range(MAX_MIX_WAIT_FRAMES):
		await tree.process_frame
		var current_mix_age := AudioServer.get_time_since_last_mix()
		if current_mix_age + MIX_AGE_RESET_TOLERANCE < previous_mix_age:
			return frame_index + 1
		previous_mix_age = current_mix_age

	return -1


func _build_result(errors: Array[String]) -> Dictionary:
	return {
		"errors": errors,
		"frames_waited": -1,
		"diagnostic": ""
	}
