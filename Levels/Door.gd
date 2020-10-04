extends Node2D

export var tween_time: float = 1.5

enum State {
	open,
	closed,
	closing,
	opening
}

var state = State.closed

func open():
	if state == State.closed:
		state = State.opening
		$Tween.interpolate_property(
			$Slider, "position", 
			Vector2(0,0), Vector2(0, -57), 
			tween_time, Tween.TRANS_LINEAR
		)
		$Tween.start()
		$Timer.start(tween_time)

func close():
	if state == State.open:
		state = State.closing
		$Tween.interpolate_property(
			$Slider, "position", 
			Vector2(0, -47), Vector2(0,0), 
			tween_time, Tween.TRANS_LINEAR
		)
		$Tween.start()
		$Timer.start(tween_time)

func animation_done():
	if state == State.closing:
		state = State.closed
	if state == State.opening:
		state = State.open

func _process(delta):
	if state >= State.closing:
		$Holder.animation = "moving"
	else:
		$Holder.animation = "idle"

#	if Input.is_action_just_pressed("z"):
#		open()
#	
#	if Input.is_action_just_pressed("x"):
#		close()
