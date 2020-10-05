extends KinematicBody2D

export var movement_speed: float = 18 * 5
export var crawl_speed_multiplier: float = 0.25
export var world_root: NodePath
export var bullet_scene: PackedScene
export var wall_jump_speed_multiplier: float = 1.5
export var bullet_speed: float = 450
export var crouch_shrinking: Vector2 = Vector2(0,6)
export var slide_shrinking: Vector2 = Vector2(0,14)
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

var upgrades: Dictionary = Dictionary()

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
	stand_to_air,
	
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
	slide_to_air,
	
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
		State.stand_to_air:
			state = State.air

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
			slide_shrink()
			$Particles/Slide.emitting = true
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
			slide_shrink()
			$Particles/Slide.emitting = true
			slide_counter = slide_time
			state = State.slide
		
		State.slide_to_crouch:
			if not slide_unshrink():
				slide_shrink()
				state = State.slide
				return
			crouch_shrink()
			$Particles/Slide.emitting = false
			state = State.crouch
		State.slide_to_crawl:
			if not slide_unshrink():
				slide_shrink()
				state = State.slide
				return
			crouch_shrink()
			$Particles/Slide.emitting = false
			state = State.crawl
		State.slide_to_stand:
			if not slide_unshrink():
				slide_shrink()
				state = State.slide
				return
			$Particles/Slide.emitting = false
			state = State.stand
		State.slide_to_run:
			if not slide_unshrink():
				slide_shrink()
				state = State.slide
				return
			$Particles/Slide.emitting = false
			state = State.run
		State.slide_to_jump:
			if not slide_unshrink():
				slide_shrink()
				state = State.slide
				return
			$Particles/Slide.emitting = false
			state = State.jump
		State.slide_to_air:
			if not slide_unshrink():
				slide_shrink()
				state = State.slide
				return
			$Particles/Slide.emitting = false
			state = State.air
			
		
		_:
			push_warning("warning, got unrecognized state-transition: " + state_to_name(state))
	print("new state: ", state_to_name(state))

func do_state(delta: float):
	match state:
		State.stand:
			$Sprites.animation = "idle"
			stand(delta)
		State.run:
			$Sprites.animation = "run"
			run(delta)
		State.jump:
			$Sprites.animation = "jump"
			jump(delta)
		State.air:
			$Sprites.animation = "air"
			air(delta)
		State.crouch:
			$Sprites.animation = "crouch"
			crouch(delta)
		State.crawl:
			$Sprites.animation = "crawl"
			crawl(delta)
		State.slide:
			$Sprites.animation = "slide"
			slide(delta)
		_:
			$Sprites.animation = "air"			
			state = State.air
			air(delta)

func stand(delta):
	velocity = Vector2(0,24)
	jump_count = 0
	
	move_and_slide(velocity, Vector2(0,-1))
	if not is_on_floor():
		state = State.stand_to_air
	
	if Input.is_action_pressed("move_left") != Input.is_action_pressed("move_right"):
		if Input.is_action_pressed("move_left"):
			state = State.stand_to_run
		if Input.is_action_pressed("move_right"):
			state = State.stand_to_run
	if Input.is_action_pressed("jump"):
		state = State.stand_to_jump
	if Input.is_action_pressed("crouch"):
		state = State.stand_to_crouch

func run(delta):
	velocity.y = gravity
	velocity.x = 0
	jump_count = 0

	if Input.is_action_pressed("move_left") != Input.is_action_pressed("move_right"):
		if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
			velocity.x = movement_speed
		if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
			velocity.x = -movement_speed
	
	move_and_slide(velocity, Vector2(0,-1))

	if Input.is_action_pressed("move_left") == Input.is_action_pressed("move_right"):
		state = State.run_to_stand
	if not is_on_floor():
		state = State.run_to_air
		velocity.y = 0
	if is_on_wall():
		state = State.run_to_stand
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
	
	if Input.is_action_pressed("move_left") != Input.is_action_pressed("move_right"):
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

func shrink(shrink_size: Vector2):
	print("shrink")
	$CollisionShape2D.position += shrink_size
	$Gun.position += shrink_size
	$CollisionShape2D.shape.extents -= shrink_size

func unshrink(shrink_size: Vector2):
	print("unshrink")
	$CollisionShape2D.position -= shrink_size
	$Gun.position -= shrink_size
	$CollisionShape2D.shape.extents += shrink_size
	var original_pos = Vector2(round(global_position.x), round(global_position.y))
	global_position.y -= 1
	if check_if_stuck():
		global_position.y += 1
		return false
	else:
		global_position.y += 1
		return true
		
	
func crouch_unshrink():
	return unshrink(crouch_shrinking)

func crouch_shrink():
	shrink(crouch_shrinking)

func crouch(delta):
	velocity.x = 0
	velocity.y = 24
	move_and_slide(velocity, Vector2(0,-1))

	if Input.is_action_pressed("move_left") != Input.is_action_pressed("move_right"):
		state = State.crouch_to_crawl
	
	if not Input.is_action_pressed("crouch"):
		state = State.crouch_to_stand

func crawl(delta):
	jump_count = 0
	velocity.y = 24
	
	if Input.is_action_pressed("move_left") != Input.is_action_pressed("move_right"):
		if (Input.is_action_pressed("move_right") and velocity.x < movement_speed):
			velocity.x = movement_speed * crawl_speed_multiplier
		if (Input.is_action_pressed("move_left") and velocity.x > -movement_speed):
			velocity.x = -movement_speed * crawl_speed_multiplier
	
	move_and_slide(velocity, Vector2(0,-1))
	
	if not is_on_floor():
		state = State.crawl_to_air
	if Input.is_action_pressed("crouch"):
		if Input.is_action_pressed("move_left") == Input.is_action_pressed("move_right"):
			state = State.crawl_to_crouch
	else:
		state = State.crawl_to_run

func slide_shrink():
	shrink(slide_shrinking)

func slide_unshrink():
	return unshrink(slide_shrinking)

func slide_move(delta):
	slide_counter -= delta
	jump_count = 0
	
	var slide_speed = movement_speed * slide_multiplier * max(slide_counter / slide_time, 0.1)
	
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
	
	if not is_on_floor():
		state = State.slide_to_air

func slide(delta):
	if facing_right:
		if Input.is_action_pressed("move_right"):
			slide_move(delta)
		elif Input.is_action_pressed("crouch"):
			state = State.slide_to_crouch
		elif Input.is_action_pressed("move_left"):
			state = State.slide_to_run
		else:
			state = State.slide_to_stand
	else:
		if Input.is_action_pressed("move_left"):
			slide_move(delta)
		elif Input.is_action_pressed("crouch"):
			state = State.slide_to_crouch
		elif Input.is_action_pressed("move_right"):
			state = State.slide_to_run
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

func can_flip():
	return state != State.slide and state < State.stand_to_crouch

var i = 0
func _process(delta):
	if can_flip() and Input.is_action_pressed("move_left") != Input.is_action_pressed("move_right"):
		if facing_right and Input.is_action_pressed("move_left"):
				$Sprites.flip_h = true
				$Gun.position = Vector2(-arm_position.x, arm_position.y)
				$Gun/Sprite.position = Vector2(gun_position.x, -gun_position.y)
				$Gun/Sprite.rotation = PI
				$Gun/Sprite.flip_h = true
				$Particles/Slide.position = Vector2(-$Particles/Slide.position.x, $Particles/Slide.position.y)
				$Particles/Slide.process_material.direction = Vector3(
					-$Particles/Slide.process_material.direction.x,
					$Particles/Slide.process_material.direction.y,
					$Particles/Slide.process_material.direction.z
				)
				facing_right = false
		elif !facing_right and Input.is_action_pressed("move_right"):
				$Sprites.flip_h = false
				$Gun.position = arm_position
				$Gun/Sprite.position = gun_position
				$Gun/Sprite.rotation = 0
				$Gun/Sprite.flip_h = false
				$Particles/Slide.position = Vector2(-$Particles/Slide.position.x, $Particles/Slide.position.y)
				$Particles/Slide.process_material.direction = Vector3(
					-$Particles/Slide.process_material.direction.x,
					$Particles/Slide.process_material.direction.y,
					$Particles/Slide.process_material.direction.z
				)
				facing_right = true
	
	
	$Gun.look_at(get_global_mouse_position())
	move_and_slide(velocity, Vector2(0,-1))

	if state > State.wall_jump:
		do_transition(delta)
	
	do_state(delta)
	
	if Input.is_action_just_pressed("fire"):
		fire()
	
	

func check_if_stuck():
	return test_move(transform, Vector2(1,0)) and \
		   test_move(transform, Vector2(-1,0)) and \
		   test_move(transform, Vector2(0,1)) and \
		   test_move(transform, Vector2(0,-1))

func give_upgrade(id: String):
	print("aaa")
	upgrades[id] = true
