extends Node3D

@onready var smoke: GPUParticles3D = $Smoke


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	smoke.emitting = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
