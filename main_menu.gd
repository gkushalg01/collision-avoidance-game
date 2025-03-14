extends Node2D


func _on_start_game_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_game.tscn")
	

func _on_create_map_button_pressed() -> void:
	get_tree().change_scene_to_file("res://map_creator.tscn")
