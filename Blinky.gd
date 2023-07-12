extends "res://Ghost.gd"

func showTarget(t):
	maze.get_node("Debug2").position = maze.map_to_world(t) + maze.cell_size / 2

func getScatterTarget():
	if maze.getElroy() == 0:
		var t = maze.get_node('InfoTiles').get_used_cells_by_id(0)
		return t[0]	
	else:
		return getChaseTarget()

func getSpeed():
	var s
	var tunnel = (currentTile in maze.get_node("InfoTiles").get_used_cells_by_id(11))
	match state:
		states.WAITING:
			s = maze.waitSpeed
		states.SPAWNING:
			s = maze.waitSpeed
		states.SCATTER:
			s = maze.ghostSpeed
			var e = maze.getElroy()
			if e == 1:
				s = maze.elroy1Speed
			elif e == 2:
				s = maze.elroy2Speed
			if tunnel:
				s = maze.tunnelSpeed
		states.CHASE:
			s = maze.ghostSpeed
			var e = maze.getElroy()
			if e == 1:
				s = maze.elroy1Speed
			elif e == 2:
				s = maze.elroy2Speed
			if tunnel:
				s = maze.tunnelSpeed
		states.BLUE:
			s = maze.blueSpeed
		states.FLASHING:
			s = maze.blueSpeed
		states.EYES:
			s = maze.eyesSpeed
		states.RESPAWNING:
			s = maze.eyesSpeed
	return s
