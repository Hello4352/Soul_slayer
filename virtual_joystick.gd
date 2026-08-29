extends Control

var output := Vector2.ZERO
var _touch_index := -1

func _draw():
    var center = size / 2
    draw_circle(center, 80, Color(1, 1, 1, 0.2))
    draw_circle(center + output * 80, 30, Color(1, 1, 1, 0.5))

func _input(event):
    if event is InputEventScreenTouch:
        _handle_touch(event)
    elif event is InputEventScreenDrag:
        _handle_drag(event)

func _handle_touch(event):
    if event.pressed:
        _try_start_touch(event)
        return
    if event.index != _touch_index:
        return
    _touch_index = -1
    output = Vector2.ZERO
    queue_redraw()

func _try_start_touch(event):
    if _touch_index != -1:
        return
    var local_pos = event.position - global_position
    if local_pos.distance_to(size / 2) > 100:
        return
    _touch_index = event.index
    _update_output(event.position)

func _handle_drag(event):
    if event.index == _touch_index:
        _update_output(event.position)

func _update_output(pos: Vector2):
    var local_pos = pos - global_position - size / 2
    output = local_pos.limit_length(80) / 80
    queue_redraw()
