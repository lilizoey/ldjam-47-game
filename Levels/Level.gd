extends Node2D

signal player_hit_loading_zone(level, target_zone)

var player: KinematicBody2D

func _ready():
	if get_node_or_null("Midground/Player"):
		player = $Midground/Player

func get_player():
	return player

func remove_player():
	player.get_parent().remove_child(player)

func place_player_at(new_player: KinematicBody2D, zone: String):
	var new_global_pos = get_target_global_position(zone)
	new_player.global_position = new_global_pos
	$Midground.add_child(new_player)
	player = new_player

func _on_LoadingZones_player_hit_transition(level, target_zone):
	emit_signal("player_hit_loading_zone", level, target_zone)

func get_target_global_position(target_zone):
	var node = get_node_or_null("TargetZones/" + target_zone)
	if node:
		return node.global_position
	else:
		return Vector2(0,0)
