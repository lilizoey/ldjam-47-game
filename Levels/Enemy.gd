extends KinematicBody2D

export var move_right: bool = true
export var movement_speed: float = 30
export var gravity: float = 9.81 * 18

var velocity = Vector2(0,0)

func _ready():
	pass # Replace with function body.

func move(delta):
	move_and_slide(velocity, Vector2(0,-1))
	var start_pos = position
	
	move_and_slide(Vector2(0,1), Vector2(0,-1))
	
	if not is_on_floor():
		position = start_pos
		move_right = !move_right
		velocity.x = -velocity.x
		move_and_slide(velocity, Vector2(0,-1))

func _process(delta):
	move(delta)
	
	if is_on_floor():
		velocity.y = 0
		
	velocity += Vector2(0, gravity * delta)
	
	if move_right:
		velocity.x = movement_speed
	if !move_right:
		velocity.x = -movement_speed
