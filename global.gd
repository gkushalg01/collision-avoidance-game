extends Node2D

var _astar2D := AStar2D.new()
@export var WAYPOINT_SIZE:= 15
@export var PATH_WIDTH:= 20
const MAP_SAVE_PATH:= "res://map.save"


func LoadMap() -> void:
	if(not FileAccess.file_exists(MAP_SAVE_PATH)): return
	var config := ConfigFile.new()
	var nodeToPos := {}
	var nodeConnections := {}
	config.load(MAP_SAVE_PATH)
	nodeToPos = config.get_value("waypoints", "nodeToPos")
	nodeConnections = config.get_value("waypoints", "nodeConnections")
	
	if(nodeToPos.size() < 1): return
	Global._astar2D.clear()
	
	for node in nodeToPos:
		Global._astar2D.add_point(node, nodeToPos[node])
	for node in nodeConnections:
		for connection in nodeConnections[node]:
			Global._astar2D.connect_points(node, connection)


func SaveMap() -> void:
	var config := ConfigFile.new()
	var nodeToPos := {}
	var nodeConnections := {}
	
	for i in Global._astar2D.get_point_ids():
		nodeToPos[i] = Global._astar2D.get_point_position(i)
		nodeConnections[i] = Global._astar2D.get_point_connections(i)
	config.set_value("waypoints", "nodeToPos", nodeToPos)
	config.set_value("waypoints", "nodeConnections", nodeConnections)
	config.save(MAP_SAVE_PATH)
