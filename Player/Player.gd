extends KinematicBody2D

export var movement_speed: float = 18 * 5
export var crawl_speed_multiplier: float = 0.25
export var world_root: NodePath
export var bullet_scene: PackedScene
export var wall_jump_speed_multiplier: float = 1.5
export var bullet_speed: float = 450
export var crouch_shrinking: Vector2 = Vector2(0,12)
export var air_float_multiplier: float = 0.5
export var gravity: float = 24 * 9.81
export var jump_speed: float = gravity * 0.35
export var slide_time: float = 0.6
export var slide_multiplier: float = 2


var facing_right = true
var mouse_position: Vector2 = Vector2(0,0)
var velocity: Vector2 = Vector2(0,0)

var max_jumps: int = 2
var jump_count: int = 0
var bullet_offset: Vector2 = Vector2(0,-6)

var slide_counter: float = slide_time

onready var arm_position: Vector2 = $Gun.position
onready var gun_position: Vector2 = $Gun/Sprite.position

enum State {
	stand,
	run,
	crouch,
	crawl,
	slide,
	jump,
	air,
	wall_hang,
	wall_jump,
	
	stand_to_crouch,
	stand_to_run,
	stand_to_jump,
	
	run_to_stand,
	run_to_slide,
	run_to_jump,
	run_to_air,
	
	crouch_to_stand,
	crouch_to_jump,
	crouch_to_crawl,
	
	crawl_to_jump,
	crawl_to_crouch,
	crawl_to_air,
	crawl_to_run,
	
	slide_to_crouch,
	slide_to_crawl,
	slide_to_stand,
	slide_to_run,
	slide_to_jump,
	
	jump_to_air,
	
	air_to_jump,
	air_to_stand,
	air_to_run,
	air_to_slide,
	air_to_crouch,
	air_to_wall_hang,
	
	wall_hang_to_wall_jump,
	wall_hang_to_air,
	wall_hang_to_stand,
	
	wall_jump_to_air,
}

func state_to_name(state: int) -> String:
	match state:
		State.stand:
			return "stand"
		State.run:
			return "run"
		State.crouch:
			return "crouch"
		State.crawl:
			return "crawl"
		State.slide:
			return "slide"
		State.jump:
			return "jump"
		State.air:
			return "air"
		State.wall_hang:
			return "wall hang"
		State.wall_jump:
			return "wall jump"
		_:
			return str(state)

var state: int = State.air

export var max_hang_velocity: float = gravity * 0.1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func do_transition(delta: float):
	match state:
		State.stand_to_crouch:
			crouch_shrink()
			state = State.crouch
		State.stand_to_jump:
			state = State.jump
		State.stand_to_run:
			state = State.run

		State.crouch_to_stand:
			crouch_unshrink()
			state = State.stand
		State.crouch_to_crawl:
			state = State.crawl

		
		State.crawl_to_crouch:
			state = State.crouch
		State.crawl_to_air:
			crouch_unshrink()
			state = State.air
		State.crawl_to_run:
			crouch_unshrink()
			state = State.run
			
		State.run_to_jump:
			state = State.jump
		State.run_to_air:
			state = State.air
		State.run_to_stand:
			state = State.stand
		State.run_to_slide:
			crouch_shrink()
			slide_counter = slide_time
			state = State.slide
			
		State.jump_to_air:
			state = State.air

		State.air_to_jump:
			state = State.jump
		State.air_to_run:
			state = State.run
		State.air_to_stand:
			state = State.stand
		State.air_to_crouch:
			crouch_shrink()
			state = State.crouch
		State.air_to_slide:
			crouch_shrink()
			slide_counter = slide_time
			state = State.slide
		
		State.slide_to_crouch:
			state = State.crouch
		State.slide_to_crawl:
			state = State.crawl
		State.slide_to_stand:
			crouch_unshrink()
			state = State.stand
		State.slide_to_run:
			crouch_unshrink()
			state = State.run
		State.slide_to_jump:
			crouch_unshrink()
			state = State.jump
		
		_:
			push_warning("warning, got unrecognized state-transition: " + state_to_name(state))
	print("new state: ", state_to_name(state))

func do_state(delta: float):
	match state:
		State.stand:
			stand(delta)
		State.run:
			run(delta)
		State.jump:
			jump(delta)
		State.air:
			air(delta)
		State.crouch:
			crouch(delta)
		State.crawl:
			crawl(delta)
		State.slide:
			slide(delta)
		_:
			state = State.air
			air(delta)

func stand(delta):
	velocity = Vector2(0,0)
	jump_count = 0
	
	if Input.is_action_pressed("move_left"):
		state = State.stand_to_run
	if Input.is_action_pressed("move_right"):
		state = State.stand_to_run
	if Input.is_action_pressed("jump"):
		state = State.stand_to_jump
	if Input.is_action_pressed("crouch"):
		state = State.stand_to_crouch

func run(delta):
	velocity.y = 24
	jump_count = 0
	
	if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
		velocity.x = movement_speed
	if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
		velocity.x = -movement_speed
	
	move_and_slide(velocity, Vector2(0,-1))

	if not (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
		state = State.run_to_stand	
	if not is_on_floor():
		state = State.run_to_air
	if Input.is_action_pressed("jump"):
		state = State.run_to_jump
	if Input.is_action_pressed("crouch"):
		state = State.run_to_slide

func jump(delta):
	if jump_count < max_jumps:
		velocity.y = -jump_speed
		jump_count += 1
	state = State.jump_to_air

func air(delta):
	
	if Input.is_action_pressed("jump"):
		velocity.y += gravity * delta * air_float_multiplier
	else:
		velocity.y += gravity * delta
		
	if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
		velocity.x += min(movement_speed - velocity.x, movement_speed) * delta * 10
	if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
		velocity.x -= min(movement_speed + velocity.x, movement_speed) * delta * 10
	
	move_and_slide(velocity, Vector2(0,-1))
	
	if is_on_ceiling():
		velocity.y = 0
	
	if is_on_floor():
		if (facing_right and Input.is_action_pressed("crouch") and Input.is_action_pressed("move_right")) or \
		   (!facing_right and Input.is_action_pressed("crouch") and Input.is_action_pressed("move_left")):
			state = State.air_to_slide
		elif Input.is_action_pressed("crouch"):
			state = State.air_to_crouch
		else:
			state = State.air_to_stand
	
	if Input.is_action_just_pressed("jump"):
		state = State.air_to_jump

func crouch_unshrink():
	print("unshrink")
	position -= crouch_shrinking
	$CollisionShape2D.shape.extents += crouch_shrinking

func crouch_shrink():
	print("shrink")
	position += crouch_shrinking
	$CollisionShape2D.shape.extents -= crouch_shrinking

func crouch(delta):
	velocity.x = 0
	velocity.y = 24
	move_and_slide(velocity, Vector2(0,-1))

	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		state = State.crouch_to_crawl
	
	if not Input.is_action_pressed("crouch"):
		state = State.crouch_to_stand

func crawl(delta):
	jump_count = 0
	velocity.y = 24
	
	if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
		velocity.x = movement_speed * crawl_speed_multiplier
	if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
		velocity.x = -movement_speed * crawl_speed_multiplier
	
	move_and_slide(velocity, Vector2(0,-1))
	
	if not is_on_floor():
		state = State.crawl_to_air
	if Input.is_action_pressed("crouch"):
		if not (Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")):
			state = State.crawl_to_crouch
	else:
		state = State.crawl_to_run

func slide_move(delta):
	slide_counter -= delta
	jump_count = 0
	
	var slide_speed = movement_speed * slide_multiplier * (slide_counter / slide_time)
	
	if slide_counter <= 0:
		if Input.is_action_pressed("crouch"):
			if (Input.is_action_pressed("move_right") and facing_right) or (Input.is_action_pressed("move_left") and !facing_right):
				state = State.slide_to_crawl
			else:
				state = State.slide_to_crouch
		else:
			if (Input.is_action_pressed("move_right") and facing_right) or (Input.is_action_pressed("move_left") and !facing_right):
				state = State.slide_to_run
			else:
				state = State.slide_to_stand
	
	if facing_right:
		velocity.x = slide_speed
	else:
		velocity.x = -slide_speed
	
	move_and_slide(velocity, Vector2(0,-1))

func slide(delta):
	if facing_right:
		if Input.is_action_pressed("move_right"):
			slide_move(delta)
		elif Input.is_action_pressed("move_left"):
			slide_counter -= delta
			slide_move(delta)
		else:
			if Input.is_action_pressed("crouch"):
				state = State.slide_to_crouch
			else:
				state = State.slide_to_stand
	else:
		if Input.is_action_pressed("move_left"):
			slide_move(delta)
		elif Input.is_action_pressed("move_right"):
			slide_counter -= delta
			slide_move(delta)
		else:
			if Input.is_action_pressed("crouch"):
				state = State.slide_to_crouch
			else:
				state = State.slide_to_stand
	
	if Input.is_action_pressed("jump"):
		state = State.slide_to_jump

func fire():
	var bullet: KinematicBody2D = bullet_scene.instance()
	bullet.bullet_speed = bullet_speed
	bullet.global_position = $Gun/Sprite.global_position
	var new_offset = bullet_offset
	if !facing_right:
		new_offset.y = -bullet_offset.y
	bullet.translate(new_offset.rotated($Gun.rotation))
	bullet.rotation = $Gun.rotation
	get_node(world_root).add_child(bullet)

func object_type() -> String:
	return "player"

var i = 0
func _process(delta):
	$Gun.look_at(get_global_mouse_position())
	move_and_slide(velocity, Vector2(0,-1))

	if state > State.wall_jump:
		do_transition(delta)
	
	do_state(delta)
	
	if Input.is_action_just_pressed("fire"):
		fire()
	
	if Input.is_action_just_pressed("move_left"):
			$Sprites.flip_h = true
			$Gun.position = Vector2(-arm_position.x, arm_position.y)
			$Gun/Sprite.position = Vector2(gun_position.x, -gun_position.y)
			$Gun/Sprite.rotation = PI
			$Gun/Sprite.flip_h = true
			facing_right = false
	if Input.is_action_just_pressed("move_right"):
			$Sprites.flip_h = false
			$Gun.position = arm_position
			$Gun/Sprite.position = gun_position
			$Gun/Sprite.rotation = 0
			$Gun/Sprite.flip_h = false
			facing_right = true



func apply_gravity(delta):
	velocity.y += gravity * delta

#func on_floor(delta):
#	jump_count = 0
#	apply_gravity(delta)
#	velocity = Vector2(0,0)
#	
#	if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
#		velocity.x += min(movement_speed - velocity.x, movement_speed)
#	if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
#		velocity.x -= min(movement_speed + velocity.x, movement_speed)
#	
#	if crouch_state == CrouchState.standing and Input.is_action_pressed("crouch"):
#		crouch_state = CrouchState.do_crouch
#	
#	jump(delta)

#func on_wall(delta):
#	apply_gravity(delta)
#	velocity.x = 0
#	
#	if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
#		velocity.x += min(movement_speed - velocity.x, movement_speed) * delta * 10
#	if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
#		velocity.x -= min(movement_speed + velocity.x, movement_speed) * delta * 10
#	
#	if Input.is_action_just_pressed("jump"):
#		wall_jump(delta)

#func on_ceiling(delta):
#	velocity.y = 0
#	apply_gravity(delta)

#func in_air(delta):
#	apply_gravity(delta)
#	
#	if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
#		velocity.x += min(movement_speed - velocity.x, movement_speed) * delta * 10
#	if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
#		velocity.x -= min(movement_speed + velocity.x, movement_speed) * delta * 10
#	
#	jump(delta)

func _input(event):
	pass
#	if event is InputEventMouseButton and (event as InputEventMouseButton).pressed:
#		fire()



#func walk(delta):
#	if is_on_floor():
#		if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
#			velocity.x += min(movement_speed - velocity.x, movement_speed)
#		if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
#			velocity.x -= min(movement_speed + velocity.x, movement_speed)
#	else:
#		if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
#			velocity.x += min(movement_speed - velocity.x, movement_speed) * delta * 10
#		if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
#			velocity.x -= min(movement_speed + velocity.x, movement_speed) * delta * 10

#func jump(delta):
#	if (Input.is_action_just_pressed("jump")) and max_jumps > jump_count:
#		velocity.y = -jump_speed
#		jump_count += 1

#func wall_jump(delta):
#	for i in get_slide_count():
#		var collision = get_slide_collision(i)
#		if collision.normal.x > 0 and velocity.x < 0:
#			jump_count -= 1
#			jump(delta)
#			velocity.x = jump_speed * wall_jump_speed_multiplier
#		elif collision.normal.x < 0 and velocity.x > 0:
#			jump_count -= 1
#			jump(delta)
#			velocity.x = -jump_speed * wall_jump_speed_multiplier

#func handle_crouching():
#	if crouch_state == CrouchState.do_crouch:
#		$CollisionShape2D.shape.extents -= crouch_shrinking
#		position += crouch_shrinking
#		crouch_state = CrouchState.crouched
#		print("crouch:", $CollisionShape2D.shape.extents)
#
#	if crouch_state == CrouchState.do_stand:
#		$CollisionShape2D.shape.extents += crouch_shrinking
#		position -= crouch_shrinking
#		crouch_state = CrouchState.standing
#		print("stand:", $CollisionShape2D.shape.extents)
