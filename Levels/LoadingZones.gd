extends Node2D

export var player_path: NodePath = @"../Player"
onready var player: KinematicBody2D = get_node(player_path)

signal player_hit_transition(level)

func _ready():
	for child in get_children():
		child.connect("hit_transition", self, "_on_child_hit_transition")


func _on_child_hit_transition(body, level):
	if body == player:
		emit_signal("player_hit_transition", level)
