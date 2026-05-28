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
var expected_roll = false
@onready var body = $BODY
@onready var camera_pivot = $CameraPivot
@onready var camera_arm = $CameraPivot/CameraArm
@onready var hud_hp = $"../CanvasLayer/Hud/HP"
@onready var dodge_sfx = $sounds/dodge
@onready var attack_sfx: AudioStreamPlayer = $sounds/attack
@onready var collision = $CollisionShape3D
@onready var attack_hitbox: Area3D = $BODY/AttackHitbox
@onready var hit_enemy_sfx: AudioStreamPlayer = $sounds/hit_enemy
const EXPLOSION = preload("uid://cgjpf2llv2b8d")
const SMOKE_STEP = preload("uid://dpfq4acgi117g")


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	
func _unhandled_input(event):
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
		
func _process(_delta):
	camera_pivot.rotation.x = camera_rotation.x  # Pitch
	camera_pivot.rotation.y = camera_rotation.y  # Yaw
	hud_hp.text = str(Attack_hurt_time)
	body.rotation.x = 0
	if Invincibility > 0.0:
		Invincibility -= _delta
		body.rotation.x = 1
	
	if Attack_hurt_time > 0.0:
		
		Attack_hurt_time -= _delta
		var overlapping_areas = attack_hitbox.get_overlapping_areas()
		for area in overlapping_areas:
			if area.get_parent().is_in_group("enemy"):
				if area.INVINCIBLE < 0.1:
					area.hit(Attack_Damage)
					hit_enemy_sfx.play()
	
func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * 2 * delta
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var cam_y_rotation = camera_pivot.rotation.y
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, cam_y_rotation).normalized()
	var target_velocity = direction * SPEED
	if Invincibility < 0.1:
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
	Attack_hurt_time = 0.5
	var vfx = EXPLOSION.instantiate()
	add_child(vfx)
	
func dodge():
	expected_roll = false
	Invincibility = 0.5
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera_pivot.rotation.y).normalized()
	var horizontal_velocity = direction * SPEED * 2
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z
	dodge_sfx.play()
