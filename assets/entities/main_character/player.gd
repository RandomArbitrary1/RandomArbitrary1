extends CharacterBody3D
@export var min_pitch = -80.0  # Look down limit
@export var max_pitch = 80.0 

const SPEED = 7.0
const JUMP_VELOCITY = 4.5
var SENSITIVITY = 0.003
var camera_rotation = Vector2.ZERO
@onready var camera_pivot = $CameraPivot
@onready var camera_arm = $CameraPivot/CameraArm
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		camera_rotation.x -= event.relative.y * SENSITIVITY
		camera_rotation.y -= event.relative.x * SENSITIVITY
		camera_rotation.x = clamp(camera_rotation.x,
		deg_to_rad(min_pitch),
		deg_to_rad(max_pitch))
		
func _process(_delta):
	camera_pivot.rotation.x = camera_rotation.x  # Pitch
	camera_pivot.rotation.y = camera_rotation.y  # Yaw
	
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var cam_y_rotation = camera_pivot.rotation.y
	var direction := Vector3(input_dir.x, 0, input_dir.y).rotated(Vector3.UP, cam_y_rotation).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
