extends RigidBody2D

enum State {
	still,
	touched,
	rigid,
}

export var timer: float = 2

var state = State.still

func _ready():
	pass # Replace with function body.


func _process(delta):
	if state == State.touched:
		timer -= delta
	
	if timer <= 0:
		state = State.rigid
	
	if state <= State.touched:
		mode = MODE_STATIC
	
	if state == State.rigid:
		mode = MODE_RIGID


func _on_hit_surface(body):
	print("b")
	if state == State.still and body != self and body != get_node("../Anchor"):
		print("c")
		state = State.touched
