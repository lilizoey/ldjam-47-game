extends Area2D

export var state: bool = false
export var door_path: NodePath
onready var door: Node2D = get_node(door_path)

func _process(delta):
	if state:
		$On.visible = true
		$Off.visible = false
	else:
		$On.visible = false
		$Off.visible = true


func _on_Area2D_body_entered(body):
	if !state and body.has_method("object_type") and body.object_type() == "player":
		state = true
		door.open()
