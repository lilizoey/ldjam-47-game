extends Node2D

onready var player: KinematicBody2D = $Level.get_player()

const loaded_levels: Dictionary = Dictionary()

onready var current_level: Node2D = $Level

func _ready():
	$Level.connect("player_hit_loading_zone", self, "player_hit_loading_zone")

func _process(delta):
	pass

func player_hit_loading_zone(level, target_zone):
	if loaded_levels.has(level):
		print("aaaa")
		swap_level(loaded_levels[level], target_zone)
	else:
		loaded_levels[level] = load("res://Levels/" + level + ".tscn").instance()
		swap_level(loaded_levels[level], target_zone)

func swap_level(level: Node2D, target_zone: String):
	current_level.remove_player()
	current_level.disconnect("player_hit_loading_zone", self, "player_hit_loading_zone")
	call_deferred("remove_child", current_level)
	call_deferred("insert_new_level", level, target_zone)

func insert_new_level(level: Node2D, target_zone: String):
	add_child(level)
	current_level = level
	current_level.call_deferred("place_player_at", player, target_zone)
	current_level.connect("player_hit_loading_zone", self, "player_hit_loading_zone")
