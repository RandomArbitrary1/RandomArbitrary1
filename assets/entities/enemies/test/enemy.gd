extends CharacterBody3D

@onready var body = $"."
@onready var world = get_tree().current_scene
@onready var hitbox: Area3D = $Hitbox
@onready var fire_burst: AudioStreamPlayer3D = $FireBurst
@onready var state_behaviour = $StateBehaviour
const EXPLOSION = preload("res://assets/vfx/explosion_big.tscn")
const FIREBALL = preload("res://assets/entities/attacks/fireball.tscn")
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var rotation_speed = 9.0
var char_rotation = 0.0
var timer = 0.0
var currentenemy = null
var player = false

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
func _physics_process(delta: float) -> void:
	if state_behaviour.attack:
		timer -= delta
	if timer < 0:                # attack timer
		fire()
		timer = randi_range(8,34)
		timer = float(timer) / 10
	if not is_on_floor():        # gravity
		velocity += get_gravity() * 2 * delta
	if hitbox.HEALTH < 0.1:      # death
		die()
	if body.velocity.length() > 0.1: # movement
		var target_rotation = atan2(body.velocity.x, body.velocity.z)
		char_rotation = lerp_angle(char_rotation, target_rotation, rotation_speed * delta)
		body.rotation.y = char_rotation
	move_and_slide()

func die():
	player.enemy_death(self)
	#player.win()
	queue_free()
	
func fire():
	var fireball = FIREBALL.instantiate()
	world.add_child(fireball)
	fireball.global_position = body.global_position
	fireball.global_rotation = body.global_rotation
	fire_burst.play()
