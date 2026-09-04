extends StaticBody2D

var is_open = false

func _ready():
	$DoorVisual.color = Color(1, 0, 0)
	$DoorVisual.size = Vector2(30, 130)
	$DoorVisual.position = Vector2(-15, -65)

func set_open(open: bool):
	is_open = open
	$CollisionShape2D.set_deferred("disabled", open)
	$DoorVisual.visible = not open
