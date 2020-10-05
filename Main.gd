extends Node2D


var player_scene: PackedScene  = preload("res://Player/Player.tscn")
var player: KinematicBody2D

var loaded_levels: Dictionary = Dictionary()

const start_level: PackedScene = preload("res://Levels/Start.tscn")

var current_level: Node2D


func _ready():
	player = player_scene.instance()
	var _b = player.connect("player_has_died", self, "player_death")
	start()

func start():
	current_level = start_level.instance()
	var _b = current_level.connect("player_hit_loading_zone", self, "player_hit_loading_zone")
	loaded_levels["Start"] = current_level
	add_child(current_level)
	current_level.place_player_at(player, "Start")

func _process(_delta):
	pass

func player_hit_loading_zone(level, target_zone):
	if loaded_levels.has(level):
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
	var _b = current_level.connect("player_hit_loading_zone", self, "player_hit_loading_zone")

func player_death():
	call_deferred("reset")
	
func reset():
	current_level.remove_player()
	remove_child(current_level)
	for level in loaded_levels.values():
		level.queue_free()
	loaded_levels = Dictionary()
	start()
