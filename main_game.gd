extends Node2D

@export var bot_scene: PackedScene
var _selectedWaypoints := []
var _foundPath := []
var _botID := 0

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action("mouseLeft") && event.is_pressed()):
		var currentPos: = get_global_mouse_position()
		selectPoint(currentPos)


func _ready() -> void:
	Global.LoadMap()


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
	
	drawStartEnd()
		

func drawPath(left: int, right: int) -> void:
	if(not Global._astar2D.has_point(left) or Global._astar2D.is_point_disabled(left) or Global._astar2D.is_point_disabled(right)): return
	if(Global._astar2D.are_points_connected(left, right)):
		draw_line(Global._astar2D.get_point_position(left), Global._astar2D.get_point_position(right), Color(Color.ALICE_BLUE, .25), Global.PATH_WIDTH)


func drawWaypoint(index: int) -> void:
	var p_color := Color.ROSY_BROWN if Global._astar2D.is_point_disabled(index) else Color.CHARTREUSE
	draw_circle(Global._astar2D.get_point_position(index), Global.WAYPOINT_SIZE, p_color)
	draw_string(ThemeDB.fallback_font, Global._astar2D.get_point_position(index), str(index), HORIZONTAL_ALIGNMENT_CENTER, -1, 16, Color.BLACK)


func drawStartEnd() -> void:
	if(_selectedWaypoints.size() < 1): return
	draw_circle(Global._astar2D.get_point_position(_selectedWaypoints[0]), Global.WAYPOINT_SIZE*2, Color(Color.ALICE_BLUE, .5))
	if(_selectedWaypoints.size() < 2): return
	draw_circle(Global._astar2D.get_point_position(_selectedWaypoints[-1]), Global.WAYPOINT_SIZE*2, Color(Color.ALICE_BLUE, .5))
	drawPointPath()

func drawPointPath() -> void:
	if(_foundPath.size() < 1): return
	var left = _foundPath[0]
	for i in range(1, _foundPath.size()):
		var right = _foundPath[i]
		draw_line(left, right, Color(Color.CORAL, .4), Global.PATH_WIDTH+2)
		left = right


func selectPoint(currentPos: Vector2) -> void:
	var closestPointIndex := Global._astar2D.get_closest_point(currentPos)
	if(closestPointIndex in _selectedWaypoints):
		_selectedWaypoints.erase(closestPointIndex)
	elif(Global.WAYPOINT_SIZE > currentPos.distance_to(Global._astar2D.get_point_position(closestPointIndex))):
		_selectedWaypoints.append(closestPointIndex)
	queue_redraw()


func _on_start_job_button_pressed() -> void:
	findPath()

func findPath() -> void:
	if(_selectedWaypoints.size() < 1): return
	_foundPath = Global._astar2D.get_point_path(_selectedWaypoints[0], _selectedWaypoints[-1])
	queue_redraw()


func _on_find_path_button_pressed() -> void:
	if(_selectedWaypoints.size() < 1): return
	_foundPath = Global._astar2D.get_point_path(_selectedWaypoints[0], _selectedWaypoints[-1])
	queue_redraw()


func _on_add_bot_button_pressed() -> void:
	findPath()
	var bot = bot_scene.instantiate()
	bot.position = Global._astar2D.get_point_position(_selectedWaypoints[0])
	bot.startMoving(_foundPath)
	bot.assignID(_botID)
	_botID += 1
	add_child(bot)
