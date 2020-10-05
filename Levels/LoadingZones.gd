extends Node2D

signal player_hit_transition(level, target_zone)

func _ready():
	for child in get_children():
		child.connect("hit_transition", self, "_on_child_hit_transition")


func _on_child_hit_transition(body, level, zone):
	print(zone)
	if body.has_method("object_type") and body.object_type() == "player":
		emit_signal("player_hit_transition", level, zone)
