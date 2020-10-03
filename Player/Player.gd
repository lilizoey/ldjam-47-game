extends KinematicBody2D

export var world_root: NodePath
export var bullet_scene: PackedScene
export var wall_jump_speed_multiplier: float = 1.5
export var bullet_speed: float = 450
export var crouch_shrinking: Vector2 = Vector2(0,12)

var mouse_position: Vector2 = Vector2(0,0)
var velocity: Vector2 = Vector2(0,0)
var gravity: float = 18 * 9.81
var movement_speed = 18 * 5
var jump_speed: float = gravity * 0.75

var max_jumps: int = 2
var jump_count: int = 0

enum CrouchState {
	standing,
	do_stand,
	crouched,
	do_crouch
}

var crouch_state: int = CrouchState.standing

export var max_hang_velocity: float = gravity * 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var i = 0
func _process(delta):
	$Gun.look_at(mouse_position)
	move_and_slide(velocity, Vector2(0,-1))

	if crouch_state == CrouchState.crouched and not Input.is_action_pressed("crouch"):
		crouch_state = CrouchState.do_stand
	
	if is_on_floor():
		on_floor(delta)

	elif is_on_ceiling():
		on_ceiling(delta)
	
	elif is_on_wall():
		on_wall(delta)
	
	else:
		in_air(delta)
	
	handle_crouching()


func apply_gravity(delta):
	velocity.y += gravity * delta

func on_floor(delta):
	jump_count = 0
	apply_gravity(delta)
	velocity = Vector2(0,0)
	
	if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
		velocity.x += min(movement_speed - velocity.x, movement_speed)
	if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
		velocity.x -= min(movement_speed + velocity.x, movement_speed)
	
	if crouch_state == CrouchState.standing and Input.is_action_pressed("crouch"):
		crouch_state = CrouchState.do_crouch
	
	jump(delta)

func on_wall(delta):
	apply_gravity(delta)
	velocity.x = 0
	
	if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
		velocity.x += min(movement_speed - velocity.x, movement_speed) * delta * 10
	if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
		velocity.x -= min(movement_speed + velocity.x, movement_speed) * delta * 10
	
	if Input.is_action_just_pressed("jump"):
		wall_jump(delta)

func on_ceiling(delta):
	velocity.y = 0
	apply_gravity(delta)

func in_air(delta):
	apply_gravity(delta)
	
	if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
		velocity.x += min(movement_speed - velocity.x, movement_speed) * delta * 10
	if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
		velocity.x -= min(movement_speed + velocity.x, movement_speed) * delta * 10
	
	jump(delta)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_position = event.position
	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
		fire()

func fire():
	var bullet: KinematicBody2D = bullet_scene.instance()
	bullet.bullet_speed = bullet_speed
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
	if (Input.is_action_just_pressed("jump")) and max_jumps > jump_count:
		velocity.y = -jump_speed
		jump_count += 1

func wall_jump(delta):
	for i in get_slide_count():
		var collision = get_slide_collision(i)
		if collision.normal.x > 0 and velocity.x < 0:
			jump_count -= 1
			jump(delta)
			velocity.x = jump_speed * wall_jump_speed_multiplier
		elif collision.normal.x < 0 and velocity.x > 0:
			jump_count -= 1
			jump(delta)
			velocity.x = -jump_speed * wall_jump_speed_multiplier

func handle_crouching():
	if crouch_state == CrouchState.do_crouch:
		$CollisionShape2D.shape.extents -= crouch_shrinking
		position += crouch_shrinking
		crouch_state = CrouchState.crouched
		print("crouch:", $CollisionShape2D.shape.extents)

	if crouch_state == CrouchState.do_stand:
		$CollisionShape2D.shape.extents += crouch_shrinking
		position -= crouch_shrinking
		crouch_state = CrouchState.standing
		print("stand:", $CollisionShape2D.shape.extents)
