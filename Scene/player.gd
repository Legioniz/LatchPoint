extends CharacterBody2D

@export_range(0.0, 1200.0, 10.0) var move_speed: float = 300.0
@export_range(0.0, 5000.0, 50.0) var acceleration: float = 1800.0
@export_range(0.0, 5000.0, 50.0) var friction: float = 2200.0
@export var jump_velocity: float = -500.0


func _physics_process(delta: float) -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	var target_speed := direction * move_speed
	var movement_rate := acceleration if not is_zero_approx(direction) else friction

	velocity.x = move_toward(velocity.x, target_speed, movement_rate * delta)

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	move_and_slide()
