extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var currentenemy = null

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
		


	move_and_slide()
