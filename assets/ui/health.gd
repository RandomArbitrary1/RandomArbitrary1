extends Node2D

var player = false
@onready var str: Label = $CanvasLayer/STR
@onready var hp: Label = $CanvasLayer/HP
@onready var hp_bar: ColorRect = $CanvasLayer/HPBar
@onready var hp_background: ColorRect = $CanvasLayer/HPBackground
const MAX_HP = 100.0
const BAR_MAX_WIDTH = 500.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	hp.text = str(int(player.HEALTH))
	str.text = str(player.Attack_Damage)
	update_hp(player.HEALTH)
	
func update_hp(hp: float):
	hp_bar.size.x = (hp / MAX_HP) * BAR_MAX_WIDTH
	hp_background.size.x = (100 / MAX_HP) * BAR_MAX_WIDTH
