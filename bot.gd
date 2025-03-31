extends Area2D

@export_range(10, 500, .1, "or_greater") var speed: float = 200.
@export_range(.5, 10, .1, "or_greater") var angular_speed: float = 1.
enum State { IDLE, BUSY }
const ARRIVE_DISTANCE: float = 10

var _state := State.IDLE
var _arrivedToNextPoint := false
var _path := PackedVector2Array()
var _nextPoint := Vector2()
var _id := -1

func _ready() -> void:
	rotation = (_nextPoint - position).normalized().angle()
	
func _process(delta: float) -> void:
	if(_state == State.IDLE):
		return
	
	# rotation at waypoint
	if _arrivedToNextPoint and _path.size() > 0:
		var target_angle := fmod((_nextPoint - position).normalized().angle(), TAU)
		var current_angle := fmod(rotation, TAU)

		var difference = fmod(target_angle - current_angle + PI, TAU) - PI

		if abs(difference) > 0.05:
			rotation += sign(difference) * angular_speed * delta
			rotation = fmod(rotation, TAU)
		else:
			rotation = target_angle
			_arrivedToNextPoint = false
			
		return

	# movement on path
	if(_state == State.BUSY):
		_arrivedToNextPoint = moveTo(_nextPoint)
		
		if(_arrivedToNextPoint):
			_path.remove_at(0)
			if(_path.is_empty()):
				changeState(State.IDLE)
				return
			_nextPoint = _path[0]


func moveTo(nextPoint : Vector2) -> bool:
	var dVelocity := (_nextPoint - position).normalized() * speed
	position += dVelocity * get_process_delta_time()
	#rotation = dVelocity.angle()
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


func assignID(id : int) -> void:
	_id = id
