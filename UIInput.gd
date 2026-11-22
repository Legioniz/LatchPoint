extends Node
## Adds standard gamepad face-button bindings to Godot's built-in UI actions.

const GAMEPAD_ACCEPT_BUTTON: int = JOY_BUTTON_A
const GAMEPAD_CANCEL_BUTTON: int = JOY_BUTTON_B
const ALL_GAMEPADS: int = -1


func _enter_tree() -> void:
	_ensure_joypad_binding(&"ui_accept", GAMEPAD_ACCEPT_BUTTON)
	_ensure_joypad_binding(&"ui_cancel", GAMEPAD_CANCEL_BUTTON)


func _ensure_joypad_binding(action: StringName, button_index: int) -> void:
	if not InputMap.has_action(action):
		push_error("LatchPoint UI input action is missing: %s" % action)
		return

	var event := InputEventJoypadButton.new()
	event.button_index = button_index
	event.device = ALL_GAMEPADS

	if not InputMap.action_has_event(action, event):
		InputMap.action_add_event(action, event)
