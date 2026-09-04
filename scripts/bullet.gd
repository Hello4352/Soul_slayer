extends Area2D

var speed = 400.0
var direction = Vector2.RIGHT
var damage = 10
var from_enemy = false

func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()

func _on_body_entered(body):
	if from_enemy:
		if body.name == "player" and body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
	else:
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(damage)
			queue_free()
