extends Node2D

enum TileType { WAYPOINT, PATHPOINT, OBSTACLE }
var _astar2D: = AStar2D.new()
var _currentTileType := TileType.WAYPOINT
var _selectedWaypoints := []
var _selectWaypointMode := false
var _autoConnectMode := true
var _tileId := -1
var WAYPOINT_SIZE:= 15
var PATH_WIDTH:= 20
var MAP_SAVE_PATH:= "res://map.save"


func _ready() -> void:
	_astar2D.clear()


func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action("mouseLeft") && event.is_pressed()):
		var currentPos: = get_global_mouse_position()
		if(_selectWaypointMode):
			selectPoint(currentPos)
		elif(_autoConnectMode):
			createPoint(currentPos)
		
	# To-Do Later
	#elif(event.is_action_pressed("mouseRight")):
		#_astar2D.set_point_disabled(getTileId())
		

func selectPoint(currentPos: Vector2) -> void:
	var closestPointIndex := _astar2D.get_closest_point(currentPos)
	if(closestPointIndex in _selectedWaypoints):
		_selectedWaypoints.erase(closestPointIndex)
	elif(WAYPOINT_SIZE > currentPos.distance_to(_astar2D.get_point_position(closestPointIndex))):
		_selectedWaypoints.append(closestPointIndex)
	queue_redraw()

func _process(delta: float) -> void:
	pass


func _on_make_path_check_button_toggled(toggled_on: bool) -> void:
	if(toggled_on): _currentTileType = TileType.WAYPOINT
	else: _currentTileType = TileType.OBSTACLE


func getTileId() -> int:
	_tileId += 1
	return _tileId


func _draw() -> void:
	var sizeOfMap := _astar2D.get_point_count()
	for i in _astar2D.get_point_ids():
		drawWaypoint(i)
		for j in _astar2D.get_point_connections(i):
			drawPath(j, i)
	
	for i in _selectedWaypoints:
		drawSelected(i)


func drawPath(left: int, right: int) -> void:
	if(not _astar2D.has_point(left) or _astar2D.is_point_disabled(left) or _astar2D.is_point_disabled(right)): return
	if(_astar2D.are_points_connected(left, right)):
		draw_line(_astar2D.get_point_position(left), _astar2D.get_point_position(right), Color(Color.ALICE_BLUE, .5), PATH_WIDTH)


func drawWaypoint(index: int) -> void:
	var p_color := Color.ROSY_BROWN if _astar2D.is_point_disabled(index) else Color.CHARTREUSE
	draw_circle(_astar2D.get_point_position(index), WAYPOINT_SIZE, p_color)
	draw_string(ThemeDB.fallback_font, _astar2D.get_point_position(index), str(index), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.BLACK)

func drawSelected(index: int) -> void:
	draw_circle(_astar2D.get_point_position(index), WAYPOINT_SIZE*2, Color(Color.ALICE_BLUE, .5))

func createPoint(currentPos: Vector2) -> void:
	_astar2D.add_point(getTileId(), currentPos)
	if(_currentTileType == TileType.OBSTACLE):
		_astar2D.set_point_disabled(_tileId)
	elif(_autoConnectMode && _tileId-1 >= 0 && _astar2D.has_point(_tileId-1)):
		_astar2D.connect_points(_tileId-1, _tileId)
	queue_redraw()


func _on_reset_button_pressed() -> void:
	_astar2D.clear()
	_tileId = -1
	queue_redraw()


func _on_save_button_pressed() -> void:
	var config := ConfigFile.new()
	config.set_value("waypoints", "waypoints_astar2d", _astar2D)
	config.save(MAP_SAVE_PATH)


func _on_load_button_pressed() -> void:
	var config := ConfigFile.new()
	config.load(MAP_SAVE_PATH)
	_astar2D = config.get_value("waypoints", "waypoints_astar2d", _astar2D)
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
			_astar2D.connect_points(prev_point, curr_point)
		else:
			_astar2D.disconnect_points(prev_point, curr_point)
		prev_point = curr_point
	_selectedWaypoints.clear()
	queue_redraw()
