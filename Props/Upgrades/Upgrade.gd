extends Node2D

export var upgrade_id: String

export var taken: bool = false

func _ready():
	pass # Replace with function body.


func _process(delta):
	if taken:
		$AnimatedSprite.animation = "empty"
	else:
		$AnimatedSprite.animation = "default"


func _on_Area2D_body_entered(body):
	if body.has_method("object_type") and body.object_type() == "player":
		taken = true
		body.give_upgrade(upgrade_id)

