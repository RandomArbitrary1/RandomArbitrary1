extends MeshInstance3D

@onready var area_3d: Area3D = $Area3D
var player = false

func _ready():
	player = get_tree().get_first_node_in_group("player")

func _process(delta: float) -> void:
	var overlapping_areas = area_3d.get_overlapping_areas()
	for area in overlapping_areas:
		if area.get_parent().is_in_group("player"):
			player.hit(0.5)
