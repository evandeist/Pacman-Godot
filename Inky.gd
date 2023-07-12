extends "res://Ghost.gd"

var Blinky
func _ready():
	state = states.WAITING
	startDirection = Vector2.UP
	currentDirection = startDirection
	changeFace(currentDirection)
	#changeState(states.SCATTER)
	maze = get_owner()
	Blinky = maze.get_node('AllGhosts').get_node('Blinky')
	player = maze.get_node('Player')

func getScatterTarget():
	var t = maze.get_node('InfoTiles').get_used_cells_by_id(2)
	return t[0]

func getChaseTarget():
	# intermediate tile 2 tiles in front of pac man (same pinky glitch)
	var tile = player.tile + 2*(player.direction)
	if player.direction == Vector2.UP:
		tile += (2*Vector2.LEFT)
	# Get vector from this tile to blinky's position
	var center = maze.map_to_world(tile) + maze.cell_size / 2
	var vec = Blinky.position - center
	# negate the vector
	vec = -vec
	# add this vector to intermdediate tile
	var t = maze.world_to_map(center + vec)
	#maze.get_node("Debug").position = maze.map_to_world(t) + maze.cell_size / 2
	return t
	
func showTarget(t):
	maze.get_node("Debug4").position = maze.map_to_world(t) + maze.cell_size / 2
	
func go():
	changeState(states.WAITING)
