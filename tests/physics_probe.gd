extends CharacterBody2D

var commanded_velocity: Vector2 = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	velocity = commanded_velocity
	move_and_slide()
