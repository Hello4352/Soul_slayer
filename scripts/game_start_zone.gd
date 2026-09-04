extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)
	
func _on_body_entered(body):
	if body.name == "player":
		call_deferred("_go_to_game")

func _go_to_game():
	get_tree().change_scene_to_file("res://scenes/main.tscn")
