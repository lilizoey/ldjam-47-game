extends Node2D

export var rotation_speed_degrees: float = 60
export var player_path: NodePath
export var fire_delay: float = 1.9
export var charge_time: float = 2
export var firing_time: float = 0.1
export var firing_angle_degrees: float = 10

var player: KinematicBody2D  

var rotation_speed: float = deg2rad(rotation_speed_degrees)
var firing_angle: float = deg2rad(firing_angle_degrees)

var can_fire = true

func _ready():
	call_deferred("init_player")

func _process(delta):
	if not player:
		init_player()

func init_player():
	player = get_parent().get_parent().get_parent().get_player()

func rotate_towards(delta, pos: Vector2):
	var target_angle = global_position.angle_to_point(pos)
	if target_angle > $Gun.rotation:
		$Gun.rotation += rotation_speed * delta
	if target_angle < $Gun.rotation:
		$Gun.rotation -= rotation_speed * delta
	
	return abs(target_angle - $Gun.rotation) < firing_angle


func _physics_process(delta):
	if player:
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, player.global_position, [$Base])
	
		if result and result.collider == player:
			var in_range = rotate_towards(delta, player.global_position)
			if in_range and can_fire:
				fire()

func fire():
	can_fire = false
	$ChargeUpSound.play()
	yield(get_tree().create_timer(charge_time), "timeout")
	print("poof")
	$Gun/FiringLazer.visible = true
	yield(get_tree().create_timer(firing_time), "timeout")
	$Gun/FiringLazer.visible = false
	yield(get_tree().create_timer(fire_delay), "timeout")
	can_fire = true
	
