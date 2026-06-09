extends Node3D

@onready var swish: GPUParticles3D = $Swish


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	swish.emitting = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
