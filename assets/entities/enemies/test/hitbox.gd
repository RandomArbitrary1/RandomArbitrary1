extends Area3D
var HEALTH = 5.0
var INVINCIBLE = 0.0
@onready var hp_label: Label3D = $"../HpLabel"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if INVINCIBLE > 0.0:
		INVINCIBLE -= delta
	hp_label.text = "HP: "+str(HEALTH)

func hit(damage_amount, player) -> void:
	HEALTH -= damage_amount
	INVINCIBLE = 1.0
