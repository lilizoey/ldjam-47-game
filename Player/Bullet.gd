extends KinematicBody2D

enum State {
	flying,
	embedded,
	enemy_hit,
}

var state = State.flying

export var bullet_speed: float = 120

func fly(delta):
	var collision: KinematicCollision2D = move_and_collide(Vector2(bullet_speed * delta,0).rotated(rotation))
	
	if collision and collision.collider.has_method("object_type"):
		var type: String = collision.collider.object_type()
		
		if type == "terrain":
			state = State.embedded
		
		elif type == "enemy":
			state = State.enemy_hit
			if collision.collider.has_method("bullet_hit"):
				collision.collider.bullet_hit()
		
		else:
			state = State.embedded
	elif collision:
		state = State.embedded
func embed():
	pass

func hit():
	queue_free()

func _process(delta):
	match state:
		State.flying:
			fly(delta)
		State.embedded:
			embed()
		State.enemy_hit:
			hit()
