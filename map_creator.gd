extends Node2D

enum TileType { WAYPOINT, PATHPOINT, OBSTACLE }
var _astar2D: = AStar2D.new()
var _selectedTileType := TileType.WAYPOINT
var _tileId := -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_astar2D.clear() # Replace with function body.

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
	for i in range(0, _astar2D.get_point_count()):
		var perc = float(i)/_astar2D.get_point_count()
		var wp_color := Color.ROSY_BROWN if _astar2D.is_point_disabled(i) else Color.CHARTREUSE
		draw_circle(_astar2D.get_point_position(i), 15, wp_color)
		draw_string(ThemeDB.fallback_font, _astar2D.get_point_position(i), str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.BLACK)
		#draw_rect(Rect2(_astar2D.get_point_position(i) * 32 + Vector2(50, 51), Vector2(50, 50)-Vector2.ONE), Color(perc, 1, 1-perc))


func createPoint(currentPos: Vector2) -> void:
	_astar2D.add_point(getTileId(), currentPos)
	if(_selectedTileType == TileType.OBSTACLE):
		_astar2D.set_point_disabled(_tileId)
		
	queue_redraw()
