extends KinematicBody2D


export var bullet_speed: float = 120

func _process(delta):
	move_and_collide(Vector2(bullet_speed * delta,0).rotated(rotation))
