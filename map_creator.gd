extends Node2D

enum TileType { WAYPOINT, PATHPOINT, OBSTACLE }
var _currentTileType := TileType.WAYPOINT
var _selectedWaypoints := []
var _selectWaypointMode := false
var _autoConnectMode := true
var _tileId := 0
var viewportX = DisplayServer.screen_get_size().x
var viewportY = DisplayServer.screen_get_size().x

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	var currentPos: = get_global_mouse_position()
	if(event.is_action("mouseLeft") && event.is_pressed()):
		if(_selectWaypointMode):
			selectPoint(currentPos)
		elif(_autoConnectMode):
			createPoint(currentPos)
		
	#elif(event.is_action_pressed("mouseRight") && event.is_pressed()):
		#var closestPointIndex := Global._astar2D.get_closest_point(currentPos)
		#if(Global._astar2D.is_point_disabled(closestPointIndex)):
			#Global._astar2D.set_point_enabled(Global._astar2D.get_closest_point(currentPos))
		#else:
			#Global._astar2D.set_point_disabled(Global._astar2D.get_closest_point(currentPos))
			

func selectPoint(currentPos: Vector2) -> void:
	var closestPointIndex := Global._astar2D.get_closest_point(currentPos)
	if(closestPointIndex in _selectedWaypoints):
		_selectedWaypoints.erase(closestPointIndex)
	elif(Global.WAYPOINT_SIZE > currentPos.distance_to(Global._astar2D.get_point_position(closestPointIndex))):
		_selectedWaypoints.append(closestPointIndex)
	queue_redraw()


func _on_make_path_check_button_toggled(toggled_on: bool) -> void:
	if(toggled_on): _currentTileType = TileType.WAYPOINT
	else: _currentTileType = TileType.OBSTACLE


func getTileId() -> int:
	_tileId += 1
	return _tileId


func _draw() -> void:
	var currentPos := get_global_mouse_position()
	draw_dashed_line(Vector2(currentPos.x, 0), Vector2(currentPos.x, 2000), Color(Color.AQUA, .5))
	draw_dashed_line(Vector2(0, currentPos.y), Vector2(2000, currentPos.y), Color(Color.AQUA, .5))
	var sizeOfMap := Global._astar2D.get_point_count()
	for i in Global._astar2D.get_point_ids():
		drawWaypoint(i)
		for j in Global._astar2D.get_point_connections(i):
			drawPath(j, i)
	
	for i in _selectedWaypoints:
		drawSelected(i)


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

func createPoint(currentPos: Vector2) -> void:
	Global._astar2D.add_point(getTileId(), currentPos)
	if(_currentTileType == TileType.OBSTACLE):
		Global._astar2D.set_point_disabled(_tileId)
	elif(_autoConnectMode && _tileId > 1 && Global._astar2D.has_point(_tileId-1)):
		Global._astar2D.connect_points(_tileId-1, _tileId)
	queue_redraw()


func _on_reset_button_pressed() -> void:
	Global._astar2D.clear()
	_tileId = 0
	queue_redraw()


func _on_save_button_pressed() -> void:
	Global.SaveMap()


func _on_load_button_pressed() -> void:
	Global.LoadMap()
	if(Global._astar2D.get_point_count() < 1): return
	var allPoints := Global._astar2D.get_point_ids()
	allPoints.sort()
	_tileId = allPoints[-1]
	queue_redraw()
	

func _on_connect_selected_button_pressed() -> void:
	connectSelectedWaypoints()


func _on_disconnect_selected_button_pressed() -> void:
	connectSelectedWaypoints(false)


func _on_select_waypoint_check_button_toggled(toggled_on: bool) -> void:
	_selectedWaypoints.clear()
	_selectWaypointMode = toggled_on

func connectSelectedWaypoints(connectPoints : bool = true) -> void:
	if(_selectedWaypoints.size() < 1): return
	var prev_point = _selectedWaypoints[0]
	for curr_index in range(1, _selectedWaypoints.size()):
		var curr_point = _selectedWaypoints[curr_index]
		if(connectPoints):
			Global._astar2D.connect_points(prev_point, curr_point)
		else:
			Global._astar2D.disconnect_points(prev_point, curr_point)
		prev_point = curr_point
	_selectedWaypoints.clear()
	queue_redraw()


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
