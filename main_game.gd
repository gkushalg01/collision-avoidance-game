extends Node2D


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")


func _draw() -> void:
	var sizeOfMap := Global._astar2D.get_point_count()
	for i in Global._astar2D.get_point_ids():
		drawWaypoint(i)
		for j in Global._astar2D.get_point_connections(i):
			drawPath(j, i)
	
	#for i in _selectedWaypoints:
		#drawSelected(i)


func drawPath(left: int, right: int) -> void:
	if(not Global._astar2D.has_point(left) or Global._astar2D.is_point_disabled(left) or Global._astar2D.is_point_disabled(right)): return
	if(Global._astar2D.are_points_connected(left, right)):
		draw_line(Global._astar2D.get_point_position(left), Global._astar2D.get_point_position(right), Color(Color.ALICE_BLUE, .25), Global.PATH_WIDTH)


func drawWaypoint(index: int) -> void:
	var p_color := Color.ROSY_BROWN if Global._astar2D.is_point_disabled(index) else Color.CHARTREUSE
	draw_circle(Global._astar2D.get_point_position(index), Global.WAYPOINT_SIZE, p_color)
	draw_string(ThemeDB.fallback_font, Global._astar2D.get_point_position(index), str(index), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.BLACK)

func drawSelected(index: int) -> void:
	draw_circle(Global._astar2D.get_point_position(index), Global.WAYPOINT_SIZE*2, Color(Color.ALICE_BLUE, .5))
