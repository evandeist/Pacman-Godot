extends "res://Ghost.gd"

func _ready():
	state = states.WAITING
	startDirection = Vector2.UP
	currentDirection = startDirection
	changeFace(currentDirection)
	maze = get_owner()
	player = maze.get_node('Player')


func getScatterTarget():
	var t = maze.get_node('InfoTiles').get_used_cells_by_id(3)
	return t[0]

func getChaseTarget():
	
	var d = getDistance(currentTile, player.tile)
	
	if d < 8 * maze.cell_size.x:
		return getScatterTarget()
	else:
		return player.tile

func showTarget(t):
	maze.get_node("Debug5").position = maze.map_to_world(t) + maze.cell_size / 2

func go():
	changeState(states.WAITING)
