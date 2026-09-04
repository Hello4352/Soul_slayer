extends Node

@export var clear_label_path: NodePath
@export var return_button_path: NodePath
@export var room_scene: PackedScene
@export var door_scene: PackedScene
@export var corridor_scene: PackedScene
@export var enemy_scene: PackedScene
@export var ranged_enemy_scene: PackedScene
@export var boss_enemy_scene: PackedScene
@export var player_path: NodePath
@export var room_container_path: NodePath

const TARGET_ROOM_COUNT = 6

var room_width = 800.0
var room_height = 600.0
var corridor_length = 200.0

var rooms = {}
var room_nodes = {}
var doors = {}
var built_connections = {}
var current_room_key = Vector2i.ZERO
var cleared_rooms = {}
var visited_rooms = {}
var stage_cleared = false
var boss_room_key = Vector2i.ZERO

func _ready():
	get_node(return_button_path).pressed.connect(_on_return_pressed)
	generate_dungeon()
	_determine_boss_room()
	build_dungeon()

	var player = get_node(player_path)
	player.global_position = room_nodes[Vector2i.ZERO].get_node("PlayerSpawn").global_position

	call_deferred("enter_room", Vector2i.ZERO)

func generate_dungeon():
	rooms.clear()
	var start = Vector2i.ZERO
	rooms[start] = true
	var frontier = [start]
	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]

	while rooms.size() < TARGET_ROOM_COUNT and frontier.size() > 0:
		var from = frontier[randi() % frontier.size()]
		directions.shuffle()
		var made_room = false
		for dir in directions:
			var next = from + dir
			if not rooms.has(next):
				rooms[next] = true
				frontier.append(next)
				made_room = true
				break
		if not made_room:
			frontier.erase(from)

func _determine_boss_room():
	var max_dist = -1
	for key in rooms.keys():
		if key == Vector2i.ZERO:
			continue
		var dist = abs(key.x) + abs(key.y)
		if dist > max_dist:
			max_dist = dist
			boss_room_key = key

func build_dungeon():
	for key in rooms.keys():
		var room = room_scene.instantiate()
		get_node(room_container_path).add_child(room)
		room_nodes[key] = room

	var sample_shape = room_nodes[Vector2i.ZERO].get_node("RoomArea/CollisionShape2D").shape
	if sample_shape is RectangleShape2D:
		room_width = sample_shape.size.x
		room_height = sample_shape.size.y

	var sample_corridor = corridor_scene.instantiate()
	var corridor_floor = sample_corridor.get_node("ColorRect")
	if corridor_floor:
		corridor_length = corridor_floor.size.x
	sample_corridor.queue_free()

	for key in rooms.keys():
		var room = room_nodes[key]
		room.position = Vector2(
			key.x * (room_width + corridor_length),
			key.y * (room_height + corridor_length)
		)
		room.get_node("RoomArea").body_entered.connect(_on_room_area_entered.bind(key))

	for key in rooms.keys():
		_connect_if_needed(key, key + Vector2i.UP, "DoorSlotTop", "DoorSlotBottom")
		_connect_if_needed(key, key + Vector2i.DOWN, "DoorSlotBottom", "DoorSlotTop")
		_connect_if_needed(key, key + Vector2i.LEFT, "DoorSlotLeft", "DoorSlotRight")
		_connect_if_needed(key, key + Vector2i.RIGHT, "DoorSlotRight", "DoorSlotLeft")

func _connect_if_needed(from_key, to_key, from_slot, to_slot):
	if not rooms.has(to_key):
		return
	var pair_key = str(from_key) + "_" + str(to_key)
	var reverse_key = str(to_key) + "_" + str(from_key)
	if built_connections.has(pair_key) or built_connections.has(reverse_key):
		return
	built_connections[pair_key] = true

	var is_vertical = (from_slot == "DoorSlotTop" or from_slot == "DoorSlotBottom")
	var door_rotation = 0.0 if not is_vertical else 90.0
	var corridor_rotation = 90.0 if is_vertical else 0.0

	var from_room = room_nodes[from_key]
	var to_room = room_nodes[to_key]
	var from_marker = from_room.get_node(from_slot)
	var to_marker = to_room.get_node(to_slot)

	var door_from = door_scene.instantiate()
	get_node(room_container_path).add_child(door_from)
	door_from.global_position = from_marker.global_position
	door_from.rotation_degrees = door_rotation
	door_from.set_open(true)
	doors[str(from_key) + "_" + from_slot] = door_from

	var door_to = door_scene.instantiate()
	get_node(room_container_path).add_child(door_to)
	door_to.global_position = to_marker.global_position
	door_to.rotation_degrees = door_rotation
	door_to.set_open(true)
	doors[str(to_key) + "_" + to_slot] = door_to

	var corridor = corridor_scene.instantiate()
	get_node(room_container_path).add_child(corridor)
	corridor.global_position = (from_marker.global_position + to_marker.global_position) / 2.0
	corridor.rotation_degrees = corridor_rotation

func _on_room_area_entered(body, key):
	if not body.is_in_group("player"):
		return
	call_deferred("enter_room", key)

func enter_room(key: Vector2i):
	current_room_key = key
	if cleared_rooms.has(key):
		return
	if visited_rooms.has(key):
		return
	visited_rooms[key] = true

	_lock_doors_around(key, true)
	if key == boss_room_key:
		_spawn_boss(room_nodes[key])
	else:
		_spawn_enemies_for_room(room_nodes[key])

func _lock_doors_around(key, locked):
	for slot in ["DoorSlotTop", "DoorSlotBottom", "DoorSlotLeft", "DoorSlotRight"]:
		var door_key = str(key) + "_" + slot
		if doors.has(door_key):
			doors[door_key].set_open(not locked)

func _process(_delta):
	if stage_cleared:
		return
	if cleared_rooms.has(current_room_key):
		return
	var enemies = get_tree().get_nodes_in_group("enemy")
	if enemies.size() == 0 and visited_rooms.has(current_room_key):
		_on_room_cleared()

func _on_room_cleared():
	cleared_rooms[current_room_key] = true
	_lock_doors_around(current_room_key, false)
	if cleared_rooms.size() >= rooms.size():
		stage_cleared = true
		get_node(clear_label_path).visible = true
		get_node(return_button_path).visible = true

func _spawn_enemies_for_room(room):
	var spawn_points = []
	for i in range(1, 5):
		spawn_points.append(room.get_node("SpawnPoint" + str(i)))
	spawn_points.shuffle()

	var compositions = [
		["basic", "basic"],
		["basic", "tank"],
		["ranged", "basic"],
		["tank", "ranged", "basic"],
		["ranged", "ranged"]
	]
	var composition = compositions[randi() % compositions.size()]

	for i in range(composition.size()):
		_spawn_enemy(composition[i], spawn_points[i].global_position)

func _spawn_enemy(enemy_type, pos):
	var enemy
	if enemy_type == "ranged":
		enemy = ranged_enemy_scene.instantiate()
	else:
		enemy = enemy_scene.instantiate()
		if enemy_type == "tank":
			enemy.max_hp = 90
			enemy.speed = 50.0
			enemy.contact_damage = 20
			enemy.attack_cooldown = 1.8

	get_node(room_container_path).add_child(enemy)
	enemy.global_position = pos

func _spawn_boss(room):
	var boss = boss_enemy_scene.instantiate()
	get_node(room_container_path).add_child(boss)
	boss.global_position = room.get_node("SpawnPoint1").global_position

func _on_return_pressed():
	get_tree().change_scene_to_file("res://scenes/lobby.tscn")
