extends Node3D
@onready var red_smoke: GPUParticles3D = $RedSmoke
@onready var area_3d: Area3D = $Area3D
@onready var body: Node3D = $"."
var velocity = Vector3(0,0,5)
var timer = 0.0
var speed = 15.0
var player = false
var damage = 5.0

func _ready() -> void:
	red_smoke.emitting = true
	player = get_tree().get_first_node_in_group("player")
	#area_3d.body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	timer += delta
	body.position += body.basis.z * speed * delta
	var overlapping_areas = area_3d.get_overlapping_areas()
	for area in overlapping_areas:
		if area.get_parent().is_in_group("player"):
			player.hit(damage)
			queue_free()  
			return        
	if timer > 9:
		queue_free()

#func _on_body_entered(body_hit: Node) -> void:
	#queue_free()
