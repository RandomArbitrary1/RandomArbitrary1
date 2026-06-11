extends CharacterBody3D

@onready var body = $"."
@onready var world = get_tree().current_scene
@onready var hitbox: Area3D = $Hitbox
@onready var fire_burst: AudioStreamPlayer3D = $FireBurst
@onready var state_behaviour = $StateBehaviour
const EXPLOSION = preload("res://assets/vfx/explosion_big.tscn")
const FIREBALL = preload("res://assets/entities/attacks/fireball.tscn")
const JUMP_VELOCITY = 4.5
var rotation_speed = 9.0
var char_rotation = 0.0
var timer = 0.0
var cooldown_timer = 0.0
var cooldown_duration = 0.0
var is_charging = false
var charge_time = 2.0  # seconds to charge
var charge_timer = 0.0
var fireball_interval = 1.0  # seconds between regular fireballs
var fireball_timer = 0.0
var currentenemy = null
var player = false

# Spin and shoot variables
var is_spinning = false
var spin_duration = 2.0
var spin_timer = 0.0
var spin_direction = 1.0

var original_velocity = Vector3.ZERO
var is_moving = true

# Minigun attack variables
var is_minigun_firing = false
var minigun_fire_rate = 0.1  # seconds between shots
var minigun_timer = 0.0
var minigun_shots_fired = 0
var max_minigun_shots = 20  # number of shots per burst
var minigun_accuracy = 0.2  # radians, inaccuracy

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	reset_cooldown()

func _physics_process(delta: float) -> void:
	if state_behaviour.player != null:
		currentenemy = state_behaviour.player
		
	if state_behaviour.attack:
		if cooldown_timer > 0:
			cooldown_timer -= delta
		else:
			if not is_charging:
				is_charging = true
				charge_timer = 0.0
			else:
				charge_timer += delta
				if charge_timer >= charge_time:
					fire(true)
					is_charging = false
					reset_cooldown()

		# Regular fireball shooting
		fireball_timer -= delta
		if not is_charging and fireball_timer <= 0:
			fire(false)
			fireball_timer = fireball_interval
			
		if not is_minigun_firing and randi_range(1, 150) == 1:
			start_minigun_attack()

		# Rare spin and shoot everywhere
		if not is_spinning and randi_range(1, 100) == 1:
			start_spin()

		if is_spinning:
			handle_spin(delta)

		# Handle minigun firing
		if is_minigun_firing:
			minigun_timer -= delta
			if minigun_timer <= 0 and minigun_shots_fired < max_minigun_shots and currentenemy != null:
				shoot_at_player()
				minigun_shots_fired += 1
				minigun_timer = minigun_fire_rate
			elif minigun_shots_fired >= max_minigun_shots:
				is_minigun_firing = false
	else:
		is_charging = false
		fireball_timer -= delta

	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
	if hitbox.HEALTH < 0.1:
		die()
	if body.velocity.length() > 0.1:
		var target_rotation = atan2(body.velocity.x, body.velocity.z)
		char_rotation = lerp_angle(char_rotation, target_rotation, rotation_speed * delta)
		body.rotation.y = char_rotation
	move_and_slide()

func die():
	player.enemy_death(self)
	player.win()
	queue_free()

func reset_cooldown():
	cooldown_duration = randi_range(1, 4)
	cooldown_timer = float(cooldown_duration)

func fire(giant=false):
	var fireball = FIREBALL.instantiate()
	world.add_child(fireball)
	fireball.global_position = body.global_position
	fireball.global_rotation = body.global_rotation
	fire_burst.play()

	if giant:
		fireball.scale = Vector3(3, 3, 3)
		fireball.damage = 15
		fireball.speed = 18
	else:
		fireball.scale = Vector3(1, 1, 1)

# Spin control functions
func start_spin():
	is_spinning = true
	spin_timer = spin_duration
	spin_direction = randf_range(-1.0, 1.0)
	
	# Stop movement and face the player
	original_velocity = velocity
	velocity = Vector3.ZERO
	is_moving = false
	
func handle_spin(delta):
	spin_timer -= delta
	if spin_timer > 0:
		# Face the player
		if currentenemy != null:
			var dir_to_player = (currentenemy.global_transform.origin - global_transform.origin).normalized()
			var target_angle = atan2(dir_to_player.x, dir_to_player.z)
			body.rotation.y = lerp_angle(body.rotation.y, target_angle, rotation_speed * delta)
		# Spin
		body.rotation.y += spin_direction * rotation_speed * delta
		# Shoot fireballs in all directions periodically
		if randi_range(1, 20) == 1:
			shoot_all_directions()
	else:
		is_spinning = false
		# Resume movement after spin
		velocity = original_velocity
		is_moving = true

func shoot_all_directions():
	var directions = 8
	for i in range(directions):
		var angle = PI * 2 * i / directions
		var fireball = FIREBALL.instantiate()
		world.add_child(fireball)
		fireball.global_position = body.global_position
		fireball.global_rotation = Basis(Vector3.UP, angle).rotated(Vector3.UP, angle).get_euler()
		fireball.scale = Vector3(1, 1, 1)

# New minigun attack functions
func start_minigun_attack():
	is_minigun_firing = true
	minigun_timer = 0.0
	minigun_shots_fired = 0

func shoot_at_player():
	if currentenemy == null:
		return
	var target_pos = currentenemy.global_transform.origin
	var direction = (target_pos - global_transform.origin).normalized()

	# Add randomness for inaccuracy
	var random_angle = randf_range(-minigun_accuracy, minigun_accuracy)
	var direction_with_accuracy = -direction.rotated(Vector3.UP, random_angle).normalized()

	# Instantiate fireball
	var fireball = FIREBALL.instantiate()
	world.add_child(fireball)
	fireball.global_position = body.global_position
	fireball.global_rotation = body.global_rotation

	# Set the fireball to look at the target in the direction of shooting
	var target_position = fireball.global_position + direction_with_accuracy
	fireball.look_at(target_position, Vector3.UP)
	fireball.damage = 5
	fireball.speed = 20
