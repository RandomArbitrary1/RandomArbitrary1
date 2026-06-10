extends Node
@onready var body = $".."
var move_direction : Vector3
var wander_time : float
var player = false
var attack = false
var SPEED = 5.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	randomize_wander()
	player = get_tree().get_first_node_in_group("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var distance = (body.global_position - player.global_position).length()
	if distance < 25:
		near_player()
		attack = true
	else:
		attack = false
	#if wander_time > 0:
		#wander_time -= delta
	#else:
		#randomize_wander()
func near_player():
	var direction = (body.global_position - player.global_position).normalized()
	body.velocity = -direction * SPEED

func randomize_wander():
	move_direction = Vector3(randf_range(-1, 1), 0, randf_range(-1,1)).normalized()
	wander_time = randf_range(1, 3)
	
