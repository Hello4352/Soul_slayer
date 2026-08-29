extends CharacterBody2D

const SPEED = 200.0

@export var joystick_path: NodePath
var joystick: Control
func _ready():
    joystick = get_node(joystick_path)

func _physics_process(delta):
    var input_dir = Vector2.ZERO
    if joystick:
        input_dir = joystick.output
    velocity = input_dir * SPEED
    move_and_slide()
