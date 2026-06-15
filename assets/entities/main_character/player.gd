extends CharacterBody3D
@export var min_pitch = -80.0  # Look down limit
@export var max_pitch = 80.0 

const SPEED = 14.0
const JUMP_VELOCITY = 7.5
const ACCEL = 90.0
var SENSITIVITY = 0.003
var camera_rotation = Vector2.ZERO
var HEALTH = 100.0
var Attack_Damage = 1.0
var Invincibility = 0.0
var Attack_hurt_time = 0.0
var char_rotation = 0.0
var rotation_speed = 13.0
var roll_countdown = 0.0
var expected_roll = false
var got_hurt = false
@onready var body = $BODY
@onready var camera_pivot = $CameraPivot
@onready var camera_arm = $CameraPivot/CameraArm
@onready var dodge_sfx = $sounds/dodge
@onready var attack_sfx: AudioStreamPlayer = $sounds/attack
@onready var collision = $CollisionShape3D
@onready var attack_hitbox: Area3D = $BODY/AttackHitbox
@onready var hit_enemy_sfx: AudioStreamPlayer = $sounds/hit_enemy
@onready var hurt: AudioStreamPlayer = $sounds/hurt
@onready var hurt_notify: MeshInstance3D = $BODY/hurt_notify
@onready var idleanim: AnimationPlayer = $BODY/knight/Animations/idle
@onready var runanim: AnimationPlayer = $BODY/knight/Animations/run
@onready var dashanim: AnimationPlayer = $BODY/knight/Animations/dash
@onready var attackanim: AnimationPlayer = $BODY/knight/Animations/attack

const SWISH = preload("res://assets/vfx/swish.tscn")
const SMOKE_STEP = preload("res://assets/vfx/smoke_step.tscn")
const ENEMY_PARTICLES = preload("res://assets/vfx/explosion_big.tscn")
const ending_scene = preload("res://assets/end_scene.tscn")
const MAGIC = preload("res://assets/vfx/magic.tscn")
var playanim = "idle"
@onready var knight: Node3D = $BODY/knight
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if Input.is_action_just_pressed("pause"):
		toggle_pause()
	if get_tree().paused:
		return
	if event is InputEventMouseMotion:
		camera_rotation.x -= event.relative.y * SENSITIVITY
		camera_rotation.y -= event.relative.x * SENSITIVITY
		camera_rotation.x = clamp(camera_rotation.x,
		deg_to_rad(min_pitch),
		deg_to_rad(max_pitch))
	if Input.is_action_just_pressed("dodge"):
		expected_roll = true
	if Input.is_action_just_pressed("attack"):
		attack()
	if Input.is_action_just_pressed("fullscreen"):
		toggle_fullscreen()
	
		
func _process(_delta):
	if get_tree().paused:
		return
	HEALTH += _delta
	if HEALTH > 100.0:
		HEALTH = 100.0
	camera_pivot.rotation.x = camera_rotation.x  # Pitch
	camera_pivot.rotation.y = camera_rotation.y  # Yaw
	if Invincibility > 0.0:
		Invincibility -= _delta
	if roll_countdown > 0.0:
		roll_countdown -= _delta
	if Invincibility > 0.0:
		if got_hurt:
			hurt_notify.visible = true
	else:
		got_hurt = false
		hurt_notify.visible = false
	if Attack_hurt_time > 0.0:
		Attack_hurt_time -= _delta
		var overlapping_areas = attack_hitbox.get_overlapping_areas()
		for area in overlapping_areas:
			if area.get_parent().is_in_group("enemy"):
				if area.INVINCIBLE < 0.1:
					area.hit(Attack_Damage, self)
					var particle = SWISH.instantiate()
					add_child(particle)
					particle.global_position = area.global_position
					hit_enemy_sfx.play()
	if HEALTH < 0.1:
		playerdead()
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var is_moving = input_dir.length() > 0.1
	if Input.is_action_just_pressed("attack"):
		dashanim.stop()
		attackanim.stop()
		attackanim.play("mixamo_com")
		attackanim.speed_scale = 5
	elif is_moving:
		runanim.play("mixamo_com")
		runanim.speed_scale = 2
	else:
		runanim.stop()
		idleanim.play("mixamo_com")

func playerdead():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/gameover_scene.tscn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var cam_y_rotation = camera_pivot.rotation.y
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, cam_y_rotation).normalized()
	var target_velocity = direction * SPEED
	if roll_countdown < 0.1:
		if expected_roll:
			dodge()
	if direction.length() > 0.01:
		var target_rotation = atan2(direction.x, direction.z)
		char_rotation = lerp_angle(char_rotation, target_rotation, rotation_speed * delta)
		body.rotation.y = char_rotation
		var smoke = SMOKE_STEP.instantiate()
		smoke.position.y = body.position.y - 1
		add_child(smoke)
	#body.rotation = Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, cam_y_rotation).normalized()
	var horizontal_velocity = velocity
	horizontal_velocity = horizontal_velocity.move_toward(target_velocity, ACCEL * delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	move_and_slide()
	
func attack():
	attack_sfx.play()
	Attack_hurt_time = 0.2 # how long the attack is
	var vfx = MAGIC.instantiate()
	add_child(vfx)
	
func dodge():
	dashanim.stop()
	dashanim.play("mixamo_com")
	dashanim.speed_scale = 2.3
	expected_roll = false
	Invincibility = 0.3
	roll_countdown = 0.5
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera_pivot.rotation.y).normalized()
	var horizontal_velocity = direction * SPEED * 2
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	dodge_sfx.play()
	
func hit(damage):
	if Invincibility < 0.1:
		HEALTH -= damage
		Invincibility = 0.5
		hurt.play()
		got_hurt = true
	
func enemy_death(enemy):
	var vfx = ENEMY_PARTICLES.instantiate()
	add_child(vfx)
	vfx.global_position = enemy.global_position
	Attack_Damage += 0.5
	
func win():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://assets/end_scene.tscn")
	
	
func toggle_fullscreen():
	if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
func toggle_pause():
	get_tree().paused = !get_tree().paused
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
