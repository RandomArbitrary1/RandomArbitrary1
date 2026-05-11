extends CharacterBody3D
@export var min_pitch = -80.0  # Look down limit
@export var max_pitch = 80.0 

const SPEED = 14
const JUMP_VELOCITY = 7.5
const ACCEL = 90
var SENSITIVITY = 0.003
var camera_rotation = Vector2.ZERO
var HEALTH = 100
var Invincibility = 0
@onready var camera_pivot = $CameraPivot
@onready var camera_arm = $CameraPivot/CameraArm
@onready var hud_hp = $"../CanvasLayer/Hud/HP"
@onready var dodge_sfx = $sounds/dodge


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
		Invincibility = 1
		var input_dir := Input.get_vector("left", "right", "up", "down")
		var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, camera_pivot.rotation.y).normalized()
		var horizontal_velocity = direction * SPEED * 4
		velocity.x = horizontal_velocity.x
		velocity.z = horizontal_velocity.z
		dodge_sfx.play()
		
func _process(_delta):
	camera_pivot.rotation.x = camera_rotation.x  # Pitch
	camera_pivot.rotation.y = camera_rotation.y  # Yaw
	hud_hp.text = str(Invincibility)
	if Invincibility > 0.0:
		Invincibility -= _delta
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var cam_y_rotation = camera_pivot.rotation.y
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, cam_y_rotation).normalized()
	var target_velocity = direction * SPEED
	var horizontal_velocity = velocity
	horizontal_velocity = horizontal_velocity.move_toward(target_velocity, ACCEL * delta)
	velocity.x = horizontal_velocity.x
	velocity.z = horizontal_velocity.z

	move_and_slide()
