extends KinematicBody2D

export var world_root: NodePath
export var bullet_scene: PackedScene

var mouse_position: Vector2 = Vector2(0,0)
var velocity: Vector2 = Vector2(0,0)
var gravity: float = 18 * 9.81
var movement_speed = 18 * 5
var jump_speed: float = gravity * 0.75

export var max_hang_velocity: float = gravity * 0.1


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var i = 0
func _process(delta):
	$Gun.look_at(mouse_position)
	if is_on_floor() and velocity.y >= 0:
		velocity = Vector2(0,0)

	if is_on_wall():
		velocity.x = 0
	
	walk(delta)
	
	velocity.y += gravity * delta
	
	if is_on_wall() and abs(velocity.y) > max_hang_velocity and velocity.x != 0:
		velocity.y = clamp(velocity.y, -max_hang_velocity, max_hang_velocity)
	
	jump(delta)
	
	move_and_slide(velocity, Vector2(0,-1))


func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		fire()

func fire():
	var bullet: KinematicBody2D = bullet_scene.instance()
	bullet.global_position = $Gun/Sprite.global_position
	bullet.rotation = $Gun.rotation
	get_node(world_root).add_child(bullet)

func walk(delta):
	if is_on_floor():
		if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
			velocity.x += min(movement_speed - velocity.x, movement_speed)
		if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
			velocity.x -= min(movement_speed + velocity.x, movement_speed)
	else:
		if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
			velocity.x += min(movement_speed - velocity.x, movement_speed) * delta * 10
		if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
			velocity.x -= min(movement_speed + velocity.x, movement_speed) * delta * 10

func jump(delta):
	if (Input.is_action_just_pressed("jump")):
		if is_on_wall():
			for i in get_slide_count():
				var collision = get_slide_collision(i)
				if collision.normal.x > 0:
					velocity.x = movement_speed * 1.5
				else:
					velocity.x = -movement_speed * 1.5
		
		velocity.y = -jump_speed
