extends Area2D

@export_range(10, 500, 0.1, "or_greater") var speed: float = 200.0
enum State { IDLE, BUSY }
const ARRIVE_DISTANCE: float = 10

var _state := State.IDLE

var _path := PackedVector2Array()
var _nextPoint := Vector2()

func _ready() -> void:
	rotation = (_nextPoint - position).normalized().angle()

func _process(delta: float) -> void:
	if(_state == State.IDLE):
		return
		
	var arrivedToNextPoint: bool = moveTo(_nextPoint)
	
	if(arrivedToNextPoint):
		_path.remove_at(0)
		if(_path.is_empty()):
			changeState(State.IDLE)
			return
		_nextPoint = _path[0]


func moveTo(nextPoint : Vector2) -> bool:
	var dVelocity := (_nextPoint - position).normalized() * speed
	position += dVelocity * get_process_delta_time()
	rotation = dVelocity.angle()
	return position.distance_to(nextPoint) < ARRIVE_DISTANCE

func changeState(newState : State) -> void:
	if(newState == State.IDLE):
		_path.clear()
	elif(newState == State.BUSY):
		if(_path.size() < 2):
			changeState(State.IDLE)
			return
		_nextPoint = _path[1]
	_state = newState
	
	
func startMoving(newPath : PackedVector2Array) -> void:
	_path = newPath
	changeState(State.BUSY)
