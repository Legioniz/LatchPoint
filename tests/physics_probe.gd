extends CharacterBody2D

var commanded_velocity: Vector2 = Vector2.ZERO
var observed_floor := false
var observed_wall := false
var observed_ceiling := false


func _physics_process(_delta: float) -> void:
	velocity = commanded_velocity
	move_and_slide()

	observed_floor = observed_floor or is_on_floor()
	observed_wall = observed_wall or is_on_wall()
	observed_ceiling = observed_ceiling or is_on_ceiling()
