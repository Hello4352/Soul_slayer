extends Control

@export var stage_manager_path: NodePath
var stage_manager

const CELL_SIZE = 20
const CELL_GAP = 14

func _ready():
	stage_manager = get_node(stage_manager_path)

func _process(_delta):
	queue_redraw()

func _draw():
	if not stage_manager:
		return

	var rooms = stage_manager.rooms
	var visited = stage_manager.visited_rooms
	var cleared = stage_manager.cleared_rooms
	var current = stage_manager.current_room_key

	var center = size / 2.0 - Vector2(CELL_SIZE, CELL_SIZE) / 2.0

	var directions = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for key in visited.keys():
		for dir in directions:
			var neighbor = key + dir
			if visited.has(neighbor):
				var rel_key = key - current
				var rel_neighbor = neighbor - current
				var p1 = center + Vector2(rel_key.x, rel_key.y) * (CELL_SIZE + CELL_GAP) + Vector2(CELL_SIZE, CELL_SIZE) / 2.0
				var p2 = center + Vector2(rel_neighbor.x, rel_neighbor.y) * (CELL_SIZE + CELL_GAP) + Vector2(CELL_SIZE, CELL_SIZE) / 2.0
				draw_line(p1, p2, Color(0.8, 0.8, 0.8), 5.0)

	for key in rooms.keys():
		if not visited.has(key):
			continue

		var color = Color(0.6, 0.6, 0.6)
		if cleared.has(key):
			color = Color(0.2, 0.8, 0.2)
		if key == current:
			color = Color(1.0, 0.9, 0.1)

		var rel = key - current
		var pos = center + Vector2(rel.x, rel.y) * (CELL_SIZE + CELL_GAP)
		draw_rect(Rect2(pos, Vector2(CELL_SIZE, CELL_SIZE)), color)
