extends Node

const LEVEL : PackedScene = preload("res://scenes/level/level.tscn")
const MAIN : PackedScene = preload("res://scenes/main/main.tscn")

func load_main_scene() -> void:
	get_tree().change_scene_to_packed(MAIN)

func load_level_scene() -> void:
	get_tree().change_scene_to_packed(LEVEL)
