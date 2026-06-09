extends Node3D
@onready var red_smoke: GPUParticles3D = $RedSmoke
@onready var body: Node3D = $"."
var velocity = Vector3(0,0,5)
var timer = 0.0
var speed = 15.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	red_smoke.emitting = true


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer += delta
	body.position += body.basis.z * speed * delta
	
	if timer > 9:
		queue_free()
