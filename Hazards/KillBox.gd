extends Area2D

func _ready():
	var _b = self.connect("body_entered", self, "on_hit")

func on_hit(body):
	if body.has_method("object_type") and body.object_type() == "player":
		body.die()
