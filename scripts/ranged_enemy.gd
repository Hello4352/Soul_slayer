extends CharacterBody2D

@export var speed = 60.0
@export var max_hp = 20
@export var damage = 8
@export var shoot_cooldown = 1.5
@export var preferred_distance = 250.0
@export var player_path: NodePath
@export var bullet_scene: PackedScene

var hp
var player: Node2D
var shoot_cooldown_remaining = 0.0

func _ready():
	hp = max_hp
	if player_path:
		player = get_node(player_path)
	else:
		player = get_tree().get_first_node_in_group("player")
	add_to_group("enemy")

func _physics_process(delta):
	if shoot_cooldown_remaining > 0:
		shoot_cooldown_remaining -= delta
	if player:
		var dist = global_position.distance_to(player.global_position)
		var direction = (player.global_position - global_position).normalized()
		if dist > preferred_distance:
			velocity = direction * speed
		elif dist < preferred_distance - 30:
			velocity = -direction * speed
		else:
			velocity = Vector2.ZERO
		move_and_slide()
		if shoot_cooldown_remaining <= 0:
			shoot(direction)

func shoot(direction):
	shoot_cooldown_remaining = shoot_cooldown
	var bullet = bullet_scene.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.global_position = global_position + direction * 30
	bullet.direction = direction
	bullet.speed = 300.0
	bullet.damage = damage
	bullet.from_enemy = true

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()
