extends CharacterBody2D

const SPEED = 80.0
const MAX_HP = 30

@export var player_path: NodePath
var hp = MAX_HP
var player: Node2D

func _ready():
	if player_path:
		player = get_node(player_path)
	else:
		player = get_tree().get_first_node_in_group("player")
	print("enemy _ready, player = ", player)

func _physics_process(delta):
	if player:
		var direction = (player.global_position - global_position).normalized()
		velocity = direction * SPEED
		move_and_slide()

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()
