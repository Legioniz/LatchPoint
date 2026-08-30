extends CharacterBody2D


const SPEED = 300.0
const JUMP_VELOCITY = -500.0

var speed:float = 6000
var acceleration: float = 300
var friction: float = 50

func _physics_process(delta: float) -> void:
	var x_input: float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var velocity_weight: float = delta * (acceleration if x_input else friction)
	velocity.x = lerp(velocity.x, x_input * speed, velocity_weight)
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
