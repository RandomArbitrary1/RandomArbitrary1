extends Node3D
@onready var magic_donuts: GPUParticles3D = $"magic donuts"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	magic_donuts.emitting = true
	await get_tree().create_timer(2.0).timeout
	queue_free()
