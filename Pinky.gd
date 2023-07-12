extends "res://Ghost.gd"

func _ready():
	state = states.WAITING # TODO: THIS IS NOT TRUE OF OTHER GHOSTS
	startDirection = Vector2.DOWN
	currentDirection = startDirection
	changeFace(currentDirection)
	maze = get_owner()
	player = maze.get_node('Player')

func getScatterTarget():
	var t = maze.get_node('InfoTiles').get_used_cells_by_id(1)
	return t[0]

func getChaseTarget():
	if player.direction == Vector2.UP:
		return player.tile + 4*(Vector2.UP) + 4*(Vector2.LEFT)
	return player.tile + 4*(player.direction)
	
func showTarget(t):
	maze.get_node("Debug3").position = maze.map_to_world(t) + maze.cell_size / 2

func go():
	changeState(states.WAITING)
