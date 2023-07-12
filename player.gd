extends Node2D

signal TryAgain

enum states {STILL, MOVING, CORNERING, DYING, RESTARTING}

var spawnPosition
var direction = Vector2.LEFT
var lastInput = Vector2.LEFT
var state = states.MOVING
var tile = Vector2(0,4)
var cornering = false
var eatLag = 0
var playerSpeed = 75.75757625 * 0.8
var maze
var turning = false

# FROM WHAT I GATHER:
# Right is priotizied over left
# Up is prioritized over down
# Whe perindicular keys are pressed, the MOST RECENT CARDINAL DIRECTION is chosen
# if at the same time:
# horizontal is prioritized over vertical
# at any time, there is current input, and last input (if current is not none, last = current)
# even when there is no input at all, the last input made
# last input detrmines the way you face when stopped in a corner

# TODO: WHEN PAC MAN IS TURNING A CORNER, HE OPENS HIS MOUTH FOR 2 FRAMES
# Pac man wil linger on each frame of animation for 2 frames (MOST OF THE TIME???)
# BUT when he eats a dot he lingers on the current frame, skipping whatever frame was next
func _ready():
	maze = get_parent()
	playerSpeed = maze.playerSpeed
	spawnPosition = position

func getInput():
	#TODO: Store last non-0 input, and figure out diagonals
	var vInput = Vector2(0,0)
	if (Input.is_action_pressed("player_1_down")):
		vInput = Vector2(0,1)
	if (Input.is_action_pressed("player_1_up")): # Up is prioritized over down
		vInput = Vector2(0,-1)
	# horizontal is prioritized over vertical
	if (Input.is_action_pressed("player_1_left")):
		vInput = Vector2(-1,0)
	if (Input.is_action_pressed("player_1_right")): # Right is prioritized over left
		vInput = Vector2(1,0)
	return vInput
	
func newPlayerDirection():
	var currDirection = direction
	var vInput = getInput()
	if vInput != Vector2(0,0):
		lastInput = vInput
	if currDirection.y == 0: # we are moving horizontally
		if vInput.y != 0:
			var nextTile = (tile) + vInput
			if maze.isValidTile(nextTile) && !cornering: #TODO: actually, you can corner-cancel
				cornering = true
				turning = true
				currDirection = vInput
		elif vInput.x == currDirection.x * -1:
			currDirection = vInput
	else: # we are moving vertically
		if vInput.x != 0:
			var nextTile = (tile) + vInput
			if maze.isValidTile(nextTile) && !cornering:
				cornering = true
				turning = true
				currDirection = vInput
		elif vInput.y == currDirection.y * -1:
			currDirection = vInput
			
	direction = currDirection
	
func sgn(x):
	if x < 0:
		return -1
	elif x > 0:
		return 1
	return
	
func getDestination(worldPosition, direction, speed, delta):
	var destination = worldPosition + direction * (speed * delta)
	var destinationTile = maze.world_to_map(destination)
	var destCenter = maze.map_to_world(destinationTile) + maze.cell_size / 2
	
	# if there is no valid space beyond this one, stop in the middle of this tile
	var nextTile = destinationTile + direction
	if !maze.isValidTile(nextTile):
		if (direction.y == 0): # we are moving horizontally
			if (sgn(destCenter.x - worldPosition.x) != sgn(destCenter.x - destination.x)): # agent will overstep
				# snap to middle
				destination = destCenter
		else: # we are moving vertically
			if (sgn(destCenter.y - worldPosition.y) != sgn(destCenter.y - destination.y)): # agent will overstep
				# snap to middle
				destination = destCenter
	
	return destination
	
func corner(worldPosition, direction, speed, delta):
	var tile = maze.world_to_map(worldPosition)
	var center = maze.map_to_world(tile) + maze.cell_size / 2
	var destination
	var done = false
	
	if (direction.y == 0): # we are moving horizontally
		# snap to horizontal axis
		if (abs(center.y - worldPosition.y) > (speed * delta)): # if we won't overstep
			if (center.y < worldPosition.y): # go up
				destination = worldPosition + Vector2.UP * (speed * delta)
			else: #go down
				destination = worldPosition + Vector2.DOWN * (speed * delta)
		else: # otherwise snap to axis
			destination = Vector2(worldPosition.x, center.y)
			done = true
	else:  # we are moving vertically
		# snap to vertical axis
		if (abs(center.x - worldPosition.x) > (speed * delta)): # if we won't overstep
			if (center.x < worldPosition.x): # go left
				destination = worldPosition + Vector2.LEFT * (speed * delta)
			else: #go right
				destination = worldPosition + Vector2.RIGHT * (speed * delta)
		else: # otherwise snap to axis
			destination = Vector2(center.x, worldPosition.y)
			done = true
			
	cornering = !done
	return destination

func move(delta):
	# player movement
	newPlayerDirection()
	
	if maze.playerCaught:
		return
	
	if eatLag > 0:
		eatLag -= 1
	else:
		var d = getDestination(position, direction, playerSpeed, delta)
		if cornering:
			var c = corner(d, direction, playerSpeed, delta)
			d = c
			
		if (isMoving()):
			#print(position)
			if position == d:
				stopMoving()
			else:
				d.x = wrapf(d.x, maze.leftBound+1, maze.rightBound-1)
				position = d

		else:
			if position != d:
				startMoving()
				position = d
				
		#update player tile
		tile = maze.world_to_map(d)
		var Dots = maze.get_node("Dots")
		
		if (Dots.get_cellv(tile) == 0):
			Dots.eat(tile)
			eatLag += 1
		if  (Dots.get_cellv(tile) == 1 || Dots.get_cellv(tile) == 3):
			Dots.eat(tile)
			eatLag += 3
		

func animate():
	
	if maze.playerCaught && state != states.DYING:
		$AnimatedSprite.playing = false
		return
	else:
		$AnimatedSprite.playing = true
	
	if turning == true:
		$AnimatedSprite.frame = 2
		turning = false
	
	var d = direction
	if state == states.STILL:
		d = lastInput
	
	if d == Vector2.LEFT:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.rotation_degrees = 0
	if d == Vector2.RIGHT:
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.rotation_degrees = 0
	if d == Vector2.UP:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.flip_v = true
		$AnimatedSprite.rotation_degrees = 90
	if d == Vector2.DOWN:
		$AnimatedSprite.flip_h = false
		$AnimatedSprite.flip_v = false
		$AnimatedSprite.rotation_degrees = -90

func _process(delta):
	if maze.gameOver:
		self.hide()
		return
	if state == states.RESTARTING || state == states.DYING:
		return
	if  maze.freeze:
		$AnimatedSprite.playing = false
		self.hide()
		return
	else:
		$AnimatedSprite.playing = true
		self.show()
		animate()
		move(delta)

func startMoving():
	state = states.MOVING
	$AnimatedSprite.play("Moving")
	
func getReady():
	state = states.RESTARTING
	position = spawnPosition
	direction = Vector2.LEFT
	$AnimatedSprite.play("Ready!")

func finish():
	state = states.RESTARTING
	$AnimatedSprite.play("Ready!")

func stopMoving():
	state = states.STILL
	$AnimatedSprite.play("Still")
	
func isMoving():
	return state == states.MOVING

func die():
	state = states.DYING
	$AnimatedSprite.playing = true
	$AnimatedSprite.flip_h = false
	$AnimatedSprite.flip_v = false
	$AnimatedSprite.rotation_degrees = 0
	$AnimatedSprite.play("Die")
	$DeathSound.play()
	$DeathTimer.start()

func _on_DeathTimer_timeout():
	emit_signal("TryAgain")

func _on_Dots_PowerPelletEaten():
	playerSpeed = maze.powerSpeed

func _on_FlashingTimer_timeout():
	playerSpeed = maze.playerSpeed
