# This is mostly just to get stuff we move around. Get ready for jank.
extends Node

func get_camera() -> Node:
	return get_node("Camera2D")

func get_p1_lives() -> Node:
	return get_node("UI_node/Control/MarginContainer/VBoxContainer/MarginContainer/LivesBar/P1Lives")

func get_p2_lives() -> Node:
	return get_node("UI_node/Control/MarginContainer/VBoxContainer/MarginContainer/LivesBar/P2Lives")

func get_timer() -> Node:
	return get_node("UI_node/Control/MarginContainer/VBoxContainer/TopBar/Time")
