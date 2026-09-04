extends Area2D

@export var panel_path: NodePath

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "player":
		get_node(panel_path).visible = true
		GameData.ui_open = true
