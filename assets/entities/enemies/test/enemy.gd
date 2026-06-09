extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var currentenemy = null
@onready var hitbox: Area3D = $Hitbox
const EXPLOSION = preload("uid://ipemhx83pl")
var player = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	print(player)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
	if hitbox.HEALTH < 0.1:
		die()

	move_and_slide()

func die():
	player.enemy_death(self)
	queue_free()
