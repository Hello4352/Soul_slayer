extends CharacterBody2D

@export var speed = 50.0
@export var max_hp = 250
@export var contact_damage = 25
@export var melee_range = 60.0
@export var attack_cooldown = 1.2
@export var burst_cooldown = 3.0
@export var burst_bullet_count = 8
@export var player_path: NodePath
@export var bullet_scene: PackedScene

var hp
var player: Node2D
var attack_cooldown_remaining = 0.0
var burst_cooldown_remaining = 1.5

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
	if burst_cooldown_remaining > 0:
		burst_cooldown_remaining -= delta

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

		if burst_cooldown_remaining <= 0:
			_fire_burst()
			burst_cooldown_remaining = burst_cooldown

func _fire_burst():
	for i in range(burst_bullet_count):
		var angle = (TAU / burst_bullet_count) * i
		var direction = Vector2.RIGHT.rotated(angle)
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position + direction * 40
		bullet.direction = direction
		bullet.speed = 250.0
		bullet.damage = 10
		bullet.from_enemy = true

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		queue_free()
