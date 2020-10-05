extends Node2D


export var player_path: NodePath
onready var player: KinematicBody2D  

func _ready():
	call_deferred("init_player")

func init_player():
	player = get_parent().get_player()

func _physics_process(delta):
	if player:
		var space_state = get_world_2d().direct_space_state
		var result = space_state.intersect_ray(global_position, player.global_position, [$Base])
	
		if result and result.collider == player:
			$Gun/Sprite.look_at(player.global_position)
			$Gun/Sprite.rotate(PI)
	
	
