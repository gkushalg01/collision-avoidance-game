extends Node2D

enum TileType { WAYPOINT, PATHPOINT, OBSTACLE }
var _astar2D: = AStar2D.new()
var _selectedTileType := TileType.WAYPOINT
var _tileId := -1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_astar2D.clear() # Replace with function body.

func _input(event: InputEvent) -> void:
	#if(event.is_action("mouseLeft")):
	if(event.is_action("mouseLeft")):
		var currentPos: = get_global_mouse_position()
	
		if(_selectedTileType == TileType.WAYPOINT):
			createWaypoint(currentPos)
		#elif(_selectedTileType == TileType.OBSTACLE):
			#createObstacle(currentPos)
			#print("created obs")
			
	elif(event.is_action_pressed("mouseRight")):
		_astar2D.set_point_disabled(getTileId())
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
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
		draw_circle(_astar2D.get_point_position(i), 15, Color(perc, 1, 1-perc))
		draw_string(ThemeDB.fallback_font, _astar2D.get_point_position(i), str(i), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.BLACK)
		#draw_rect(Rect2(_astar2D.get_point_position(i) * 32 + Vector2(50, 51), Vector2(50, 50)-Vector2.ONE), Color(perc, 1, 1-perc))


func createWaypoint(currentPos: Vector2) -> void:
	_astar2D.add_point(getTileId(), currentPos)
	queue_redraw()


func createObstacle(currentPos: Vector2) -> void:
	_astar2D.add_point(getTileId(), currentPos)
