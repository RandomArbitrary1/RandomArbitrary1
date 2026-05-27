extends Node3D

@onready var explode: GPUParticles3D = $Explode

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	explode.emitting = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
