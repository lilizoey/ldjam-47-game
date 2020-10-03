extends Area2D


export var new_level: PackedScene

signal hit_transition(body, level)

func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Area2D_body_entered(body):
	emit_signal("hit_transition", body, new_level)
