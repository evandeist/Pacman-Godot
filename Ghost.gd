extends Node2D

var spawnLocation
var startDirection
var currentTile
var currentDirection
var facing # The eyes point in the direction they will go next
var turnPoint # point at current tile in which ghost turns
var turnTile # future tile at which ghost will turn
var newTileFlag # this tells us that the ghost has entered a new tile and it's time to look ahead
var speed
var turnFlag # informs this ghost that it must turn around when it gets to a new tile
var modeChangeFlag = false
var isBlue = false
var maze = get_owner()
var player

enum states {WAITING, SPAWNING, SCATTER, CHASE, BLUE, FLASHING, EYES, RESTARTING, RESPAWNING}
var animFrame
var flashFrame
var state
var exitLeft

# Called when the node enters the scene tree for the first time.
func _ready():
	animFrame = 0
	flashFrame = 0
	spawnLocation = position
	startDirection = Vector2.LEFT
	maze = get_owner()
	player = maze.get_node("Player")
	speed = maze.ghostSpeed
	currentDirection = startDirection
	exitLeft = true
	restart()

func restart():
	self.show()
	isBlue = false
	exitLeft = true
	changeState(states.RESTARTING)
	position = spawnLocation
	currentDirection = startDirection
	changeFace(currentDirection)
	updateTile()
	
func go():
	#print("scatter")
	#TODO: MAKE THIS THE STATE OF THE MAZE
	changeState(states.SCATTER)

func changeState(newState):
	if state == newState:
		return
	state = newState
	speed = maze.ghostSpeed # TEMP
	match state:
		states.WAITING:
			speed = maze.waitSpeed
		states.SPAWNING:
			speed = maze.waitSpeed
		states.SCATTER:
			# animate
			changeFace(currentDirection)
		states.CHASE:
			pass
		states.BLUE:
			speed = maze.blueSpeed
			turnFlag = true
			$AnimatedSprite.play("TURN-TO-BLUE")
			#if (!maze.isValidTile(tile + currentDirection)):
		states.FLASHING:
			speed = maze.blueSpeed
			$AnimatedSprite.play("FlashWhite")
		states.EYES:
			isBlue = false
			changeFace(facing)
			speed = maze.eyesSpeed
		

func turnAround():
	if (!maze.isValidTile(currentTile + -1*currentDirection)):
		print("UH OH STINKY POOOOOP")
		return
	turnFlag = false
	currentDirection *= -1
	facing = currentDirection
	newTileFlag = true

func changeFace(direction):
	facing = direction
	if !isBlue && (state == states.SPAWNING || state == states.WAITING || state == states.RESTARTING || state == states.SCATTER || state == states.CHASE):
		match facing:
			Vector2.UP:
				$AnimatedSprite.play("FaceUp")
			Vector2.DOWN:
				$AnimatedSprite.play("FaceDown")
			Vector2.LEFT:
				$AnimatedSprite.play("FaceLeft")
			Vector2.RIGHT:
				$AnimatedSprite.play("FaceRight")
	elif !maze.freeze && (state == states.EYES || state == states.RESPAWNING):
		match facing:	
			Vector2.UP:
				$AnimatedSprite.play("EyesUp")
			Vector2.DOWN:
				$AnimatedSprite.play("EyesDown")
			Vector2.LEFT:
				$AnimatedSprite.play("EyesLeft")
			Vector2.RIGHT:
				$AnimatedSprite.play("EyesRight")

func checkCollision():
	if (player.tile == currentTile):
		# hit
		if state == states.BLUE || state == states.FLASHING:
			# GHOST WAS EATEN
			# All other ghosts freeze, but eyes keep moving
			# Pac man and the ghost freeze and hide for a moment
			$Chomped.play()
			maze.freeze()
			var bonus = maze.ghostEaten()
			
			$AnimatedSprite.play(str(bonus))
			yield(maze.get_node('Freeze'), "timeout")
			changeState(states.EYES)
		elif state == states.SCATTER || state == states.CHASE:
			isBlue = false
			changeFace(facing) # animation fix
			if !maze.playerCaught:
				maze.playerCaught()

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
			if tunnel:
				s = maze.tunnelSpeed
		states.CHASE:
			s = maze.ghostSpeed
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

func _process(delta):
	if maze.mazeCompleted:
		return
	if maze.gameOver:
		self.hide()
		return
	# only the eyes change. the ghost bottoms consistently alternate 4 frames each
	# EVEN WHEN TRANSITIONING FROM NORMAL TO BLUE
	if modeChangeFlag && (state == states.SCATTER || state == states.CHASE):
		modeChangeFlag = false
		if maze.chaseMode:
			changeState(states.CHASE)
		else:
			changeState(states.SCATTER)
		turnFlag = true
	speed = getSpeed()
	if state != states.RESTARTING && !(maze.freeze && (state != states.EYES && state != states.RESPAWNING)):
		move(delta)
		checkCollision()
	
	if state == states.RESTARTING || (maze.freeze):
		$AnimatedSprite.playing = false
	else:
		$AnimatedSprite.playing = true
		animFrame = wrapi(animFrame + 1, 0, 15)
		anim()
	
func anim():
	# match with current animation
	var sprite = get_node("AnimatedSprite")
	var anim = sprite.animation
	if (anim == "FaceDown") || (anim == "FaceUp") || \
		(anim == "FaceLeft") || (anim == "FaceRight") || \
		(anim == "TURN-TO-BLUE"):
			flashFrame = 0
			if animFrame < 	7:
				sprite.frame = 0
			else:
				sprite.frame = 1
	elif (anim == "FlashWhite"):
		flashFrame = wrapi(flashFrame + 1, 0, 26)
		if flashFrame < 12: # white
			if animFrame < 	7:
				sprite.frame = 0
			else:
				sprite.frame = 1
		else: # blue
			if animFrame < 	7:
				sprite.frame = 2
			else:
				sprite.frame = 3

func showTarget(t):
	maze.get_node("Debug").position = maze.map_to_world(t) + maze.cell_size / 2
	
func getTargetTile():
	var t
	if state == states.SCATTER:
		t = getScatterTarget()
		#get_node("Debug").global_position = maze.map_to_world(t) + maze.cell_size / 2
		showTarget(t)
		return t 
	elif state == states.CHASE:
		t = getChaseTarget()
		#get_node("Debug").global_position = maze.map_to_world(t) + maze.cell_size / 2
		showTarget(t)
		return t
	elif state == states.EYES:
		t = getReturnTarget()
		showTarget(t)
		return t

func getReturnTarget():
	var t = maze.get_node('InfoTiles').get_used_cells_by_id(10)
	return t[0]

func getScatterTarget():
	var t = maze.get_node('InfoTiles').get_used_cells_by_id(0)
	return t[0]
	
func getChaseTarget():
	return player.tile
	
func getRandomTurn(tile):
	# IN A TIE, THE  PRIORITIES GO UP, LEFT DOWN, RIGHT	
	var possible = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	# special condition: tiles where ghosts can't go up
	if maze.get_node('InfoTiles').get_cellv(tile) == 5:
		possible.erase(Vector2.UP)
	# cannot flip around
	possible.erase(-currentDirection)
	
	if (!maze.isValidTile(tile + Vector2.RIGHT)):
		possible.erase(Vector2.RIGHT)
	if (!maze.isValidTile(tile + Vector2.UP)):
		possible.erase(Vector2.UP)
	if (!maze.isValidTile(tile + Vector2.LEFT)):
		possible.erase(Vector2.LEFT)
	if (!maze.isValidTile(tile + Vector2.DOWN)):
		possible.erase(Vector2.DOWN)
		
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var s = possible.size()
	if s == 0:
		return Vector2(0,0)
	return possible[rng.randi_range(0,s-1)]

func getBestTurn(tile):
	if state == states.BLUE || state == states.FLASHING:
		return getRandomTurn(tile)
		
	var target = getTargetTile()
	var bestTurn = Vector2(0,0)
	var bestDist = 9999999.0
	var d
	
	# IN A TIE, THE  PRIORITIES GO UP, LEFT DOWN, RIGHT	
	var possible = [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]
	# special condition: tiles where ghosts can't go up
	if maze.get_node('InfoTiles').get_cellv(tile) == 5:
		possible.erase(Vector2.UP)
	# cannot flip around
	possible.erase(-currentDirection)
	
	for v in possible:
		if maze.isValidTile(tile + v):
			d = getDistance(target, currentTile + v)
			if d <= bestDist:
				bestDist = d
				bestTurn = v
				
	if bestTurn == Vector2(0,0):
		pass
	return bestTurn
	
func getDistance(tile1, tile2):
	var world1 = maze.map_to_world(tile1)
	var world2 = maze.map_to_world(tile2)
	return world1.distance_to(world2)

func updateTile():
	var t = maze.world_to_map(position)
	if t != currentTile:
		newTileFlag = true
	currentTile = t
	
	#if (!maze.isValidTile(t)):
		#print("OOOOOOH MY GOO-OOD")
	
	if state == states.EYES && currentTile in maze.get_node('InfoTiles').get_used_cells_by_id(10):
		changeState(states.RESPAWNING)
	
func move(delta):
	if maze.playerCaught:
		return
		
	if state == states.WAITING:
		# move up and down
		if currentDirection.y > 0:
			position.y += speed*delta
			if position.y > (maze.ghostBoxCenter.y + 4):
				position.y = maze.ghostBoxCenter.y + 4
				currentDirection.y *= -1
		elif currentDirection.y < 0:
			position.y -= speed*delta
			if position.y < (maze.ghostBoxCenter.y - 4):
				position.y = maze.ghostBoxCenter.y - 4
				currentDirection.y *= -1
		changeFace(currentDirection)
		return
	
	if state == states.RESPAWNING:
		respawn(delta)
		return
	
	if state == states.SPAWNING:
		var xTarget = maze.ghostBoxCenter.x
		var yTarget = (maze.map_to_world(getReturnTarget()) + maze.cell_size / 2).y
		# move towards ghostBoxCenter.x, snap to it
		if position.x < xTarget:
			if currentDirection != Vector2.RIGHT:
				currentDirection = Vector2.RIGHT
				changeFace(currentDirection)
			position.x = clamp(position.x + (speed * delta), position.x, xTarget)
		elif position.x > xTarget:
			if currentDirection != Vector2.LEFT:
				currentDirection = Vector2.LEFT
				changeFace(currentDirection)
			position.x = clamp(position.x - (speed * delta), xTarget, position.x)
		else:
			if currentDirection != Vector2.UP:
				currentDirection = Vector2.UP
				changeFace(currentDirection)
			if position.y == yTarget:
				
				updateTile()
				if exitLeft:
					currentDirection = Vector2.LEFT
				else:
					currentDirection = Vector2.RIGHT
					print("RIGHT")
					turnFlag = false
					exitLeft = true
				changeFace(currentDirection) #TEMP?
				if isBlue:
					if $AnimatedSprite.animation == "TURN-TO-BLUE":
						changeState(states.BLUE)
					else:
						changeState(states.FLASHING)
					turnFlag = false
				else:
					if maze.chaseMode:
						changeState(states.CHASE)
					else:
						changeState(states.SCATTER)
			else:
				if position.y > yTarget:
					position.y = clamp(position.y - (speed * delta), yTarget, position.y)
		return
	
	if newTileFlag && turnFlag:
		turnAround()
	# Are we in a new tile? if so, we need to look ahead
	# and determine which way to "face"
	if newTileFlag && (facing == currentDirection):
		newTileFlag = false
		changeFace(getBestTurn(currentTile + currentDirection))
		if facing != currentDirection:
			#maze.set_cellv(currentTile + currentDirection, 25)
			turnTile = currentTile + currentDirection
			turnPoint = maze.map_to_world(turnTile) + maze.cell_size / 2
			#maze.get_node('Debug').position = turnPoint
							
	if facing != currentDirection: # if ghost intends to turn but hasn't yet
		# travel a close as you can to center, or snap to center
		# and use remaining distance to turn # NOT TRUE
		var d = turnPoint.distance_to(position)
		if (d <= (speed * delta)):
			position = turnPoint
			currentDirection = facing
			#position += currentDirection * ((maze.ghostSpeed * delta)-d) #NOT TRUE!!
		else:
			position += currentDirection * (speed * delta)
			position.x = wrapf(position.x, maze.leftBound, maze.rightBound)
	else: # going straight
		position += currentDirection * (speed * delta)
		position.x = wrapf(position.x, maze.leftBound, maze.rightBound)
	if state != states.WAITING:
		updateTile()
		
func spawnIn():
	if state == states.WAITING:
		changeState(states.SPAWNING)

func canTurnBlue():
	return !(state == states.EYES || state == states.RESTARTING)

func _on_Dots_PowerPelletEaten():
	if canTurnBlue():
		isBlue = true
		if state == states.WAITING || state == states.SPAWNING:
			#print("IM GONNA GO RIIIIGHT")
			exitLeft = false
			$AnimatedSprite.play("TURN-TO-BLUE")
		else:
			changeState(states.BLUE)

func _on_BlueTimer_timeout():
	if isBlue:
		if state == states.WAITING || state == states.SPAWNING:
			$AnimatedSprite.play("FlashWhite")
		else:
			changeState(states.FLASHING)

func _on_FlashingTimer_timeout():
		
	if state == states.BLUE || state == states.FLASHING:
		if maze.chaseMode:
			changeState(states.CHASE)
		else:
			changeState(states.SCATTER)
	isBlue = false
	if state == states.WAITING || state == states.SPAWNING:
		changeFace(facing)

func respawn(delta):
		# are you outside the ghost house? (is y position on the axis above?)
		# yes -> 
		#  are you centered with the box?
		#    yes -> move downwards
		#    no -> move towards vertical center
		# no -> # so you are entering the box
		#  are you at the bottom of the box yet?
		#    no -> move down but not past bottom
		#    yes -> 
		#     are you at spawn location yet?
		#     no -> move towards but not past spawn location
		#     yes -> change state to spawning
		
	# manually move ghost according to respawn routine
	var center = maze.ghostBoxCenter
	var aboveAxis = (maze.map_to_world(getReturnTarget()) + maze.cell_size / 2).y
	if position.y == aboveAxis:
		if position.x == center.x:
			changeFace(Vector2.DOWN)
			position.y += speed * delta
		else:
			if position.x > center.x:
				changeFace(Vector2.LEFT)
				position.x = clamp(position.x - (speed * delta), center.x, 999)
			else:
				changeFace(Vector2.RIGHT)
				position.x = clamp(position.x + (speed * delta), -999, center.x)
	else:
		if position.y != center.y+3: # TEMP
			changeFace(Vector2.DOWN)
			position.y = clamp(position.y + (speed * delta), 0, center.y+3)
		else:
			if position.x == spawnLocation.x:
				changeState(states.SPAWNING)
				if spawnLocation.x < center.x:
					changeFace(Vector2.RIGHT)
				else:
					changeFace(Vector2.LEFT)
			else:
				if spawnLocation.x < center.x:
					changeFace(Vector2.LEFT)
					position.x = clamp(position.x - (speed * delta), spawnLocation.x, 999)
				else:
					changeFace(Vector2.RIGHT)
					position.x = clamp(position.x + (speed * delta), -999, spawnLocation.x)
	
