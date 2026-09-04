extends CharacterBody2D

const AUTO_AIM_RANGE = 300.0

@export var joystick_path: NodePath
@export var attack_button_path: NodePath
@export var bullet_scene: PackedScene
@export var hp_label_path: NodePath
@export var sprite_path: NodePath

var joystick: Control
var last_direction = Vector2.DOWN
var shoot_cooldown_remaining = 0.0
var speed = 10000
var max_hp = 100
var hp = 100

func _ready():
	add_to_group("player")

	var char_data = GameData.character_data[GameData.selected_character]
	max_hp = char_data["max_hp"]
	speed = char_data["speed"]
	hp = max_hp

	if sprite_path:
		var sprite = get_node_or_null(sprite_path)
		if sprite:
			sprite.modulate = char_data["color"]
			sprite.z_index = 5

	joystick = get_node(joystick_path)
	var attack_button = get_node(attack_button_path)
	attack_button.pressed.connect(shoot)

func _physics_process(delta):
	if shoot_cooldown_remaining > 0:
		shoot_cooldown_remaining -= delta

	if hp_label_path:
		var hp_label = get_node_or_null(hp_label_path)
		if hp_label:
			hp_label.text = "HP: " + str(hp)

	if GameData.ui_open:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var input_dir = Vector2.ZERO
	if joystick:
		input_dir = joystick.output
	velocity = input_dir * speed
	if input_dir != Vector2.ZERO:
		last_direction = input_dir.normalized()
	move_and_slide()

func get_aim_direction() -> Vector2:
	var closest_enemy = null
	var closest_dist = AUTO_AIM_RANGE
	for enemy in get_tree().get_nodes_in_group("enemy"):
		var dist = global_position.distance_to(enemy.global_position)
		if dist < closest_dist:
			closest_dist = dist
			closest_enemy = enemy
	if closest_enemy:
		return (closest_enemy.global_position - global_position).normalized()
	return last_direction

func shoot():
	if shoot_cooldown_remaining > 0:
		return
	var weapon = GameData.weapon_data[GameData.selected_weapon]
	shoot_cooldown_remaining = weapon["cooldown"]
	var aim_direction = get_aim_direction()
	var count = weapon["bullet_count"]
	var spread = weapon["spread"]
	for i in range(count):
		var bullet = bullet_scene.instantiate()
		get_tree().current_scene.add_child(bullet)
		bullet.global_position = global_position
		var angle_offset = 0.0
		if count > 1:
			angle_offset = deg_to_rad(spread) * (i - float(count - 1) / 2.0)
		bullet.direction = aim_direction.rotated(angle_offset)
		bullet.speed = weapon["speed"]
		bullet.damage = weapon["damage"]

func take_damage(amount):
	hp -= amount
	if hp <= 0:
		get_tree().change_scene_to_file("res://scenes/lobby.tscn")
