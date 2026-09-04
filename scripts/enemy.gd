extends CharacterBody2D

@export var speed = 80.0
@export var max_hp = 30
@export var contact_damage = 10
@export var attack_cooldown = 1.0
@export var melee_range = 50.0
@export var player_path: NodePath

var hp
var player: Node2D
var attack_cooldown_remaining = 0.0

func _ready():
	hp = max_hp
	if player_path:
		player = get_node(player_path)
	else:
		player = get_tree().get_first_node_in_group("player")
	add_to_group("enemy")

func _physics_process(delta):
	if attack_cooldown_remaining > 0:
		attack_cooldown_remaining -= delta
	if player:
		var dist = global_position.distance_to(player.global_position)
		if dist > melee_range * 0.9:
			var direction = (player.global_position - global_position).normalized()
			velocity = direction * speed
		else:
			velocity = Vector2.ZERO
		move_and_slide()
		if dist < melee_range and attack_cooldown_remaining <= 0:
			if player.has_method("take_damage"):
				player.take_damage(contact_damage)
			attack_cooldown_remaining = attack_cooldown

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()
