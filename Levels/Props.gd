extends Node2D

func get_player():
	return get_parent().get_player()
