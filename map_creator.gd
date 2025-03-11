extends Node2D

enum TileType { WAYPOINT, PATHPOINT, OBSTACLE }
var _astar2D: = AStar2D.new()
var _selectedTileType := TileType.WAYPOINT
var _connect := true
var _tileId := -1
var WAYPOINT_SIZE:= 15
var PATH_WIDTH:= 20


func _ready() -> void:
	_astar2D.clear()


func _input(event: InputEvent) -> void:
	if(event.is_action("mouseLeft") && event.is_pressed()):
		var currentPos: = get_global_mouse_position()
		createPoint(currentPos)
		
	# To-Do Later
	#elif(event.is_action_pressed("mouseRight")):
		#_astar2D.set_point_disabled(getTileId())
		


func _process(delta: float) -> void:
	pass


func _on_make_path_check_button_toggled(toggled_on: bool) -> void:
	if(toggled_on): _selectedTileType = TileType.WAYPOINT
	else: _selectedTileType = TileType.OBSTACLE


func getTileId() -> int:
	_tileId += 1
	return _tileId


func _draw() -> void:
	var sizeOfMap := _astar2D.get_point_count()
	drawWaypoint(0)
	for i in range(1, sizeOfMap):
		drawWaypoint(i)
		drawPath(i-1, i)


func drawPath(left: int, right: int) -> void:
	if(_astar2D.is_point_disabled(left) or _astar2D.is_point_disabled(right)): return
	draw_line(_astar2D.get_point_position(left), _astar2D.get_point_position(right), Color(Color.ALICE_BLUE, .5), PATH_WIDTH)


func drawWaypoint(index: int) -> void:
	var p_color := Color.ROSY_BROWN if _astar2D.is_point_disabled(index) else Color.CHARTREUSE
	draw_circle(_astar2D.get_point_position(index), WAYPOINT_SIZE, p_color)
	draw_string(ThemeDB.fallback_font, _astar2D.get_point_position(index), str(index), HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.BLACK)


func createPoint(currentPos: Vector2) -> void:
	_astar2D.add_point(getTileId(), currentPos)
	if(_selectedTileType == TileType.OBSTACLE):
		_astar2D.set_point_disabled(_tileId)
	#elif(_connect):
		#_astar2D.connect_points(_tileId-1, _tileId)
	queue_redraw()
