extends Node2D

var player = false
@onready var str: Label = $STR
@onready var hp: Label = $HP

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hp.text = str(int(player.HEALTH))
	str.text = str(int(player.Attack_Damage))
