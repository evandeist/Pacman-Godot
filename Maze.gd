extends TileMap

signal StartLife
signal BeginGameplay
signal NewStage
signal ChangeMode
signal LostLife
signal ExtraLife

export(PackedScene) var fruit_scene

var stage = 0
var symbol = 0

const maxSpeed = 75.75757625

var playerSpeed = maxSpeed * .80
var powerSpeed = maxSpeed * .90
var ghostSpeed = maxSpeed * .75
var eyesSpeed = playerSpeed * 2.0
var blueSpeed = maxSpeed * .50
var tunnelSpeed = maxSpeed * 0.40
var waitSpeed = 30.0
var elroy1Speed = maxSpeed * .80
var elroy2Speed = maxSpeed * .85
var frightTime = 6.0 
var flashNumber = 5

var modeTimes = [7.0,20.0,7.0,20.0,5.0,20.0,5.0]
#var modeTimes = [1,1,1,1,1,1,1]

var modeTime = 0
var chaseMode = false
var elroy = 0
var freeze = false
var playerCaught = false
var mazeCompleted = false
var gameOver = false
var score = 00
const extraLifeTresh = 10000
var untilExtraLife = extraLifeTresh
var lives = 3
var ghostBoxCenter
var leftBound = -20
var rightBound = 244
var clyde
var fruit

func _ready():
	ghostBoxCenter = get_node("AllGhosts").get_node("Pinky").position
	clyde = get_node("AllGhosts").get_node("Clyde")
	emit_signal("StartLife")

func _process(delta):
		pass

func getElroy():
	if clyde.state != clyde.states.WAITING:
		return elroy
	else:
		return 0

func isValidTile(tile):
	return get_cellv(tile) == 44 # this may change!!

func freeze():
	freeze = true
	$Freeze.start()
	$Dots.get_node('BlueTimer').paused = true
	$Dots.get_node('FlashingTimer').paused = true
	
func playerCaught():
	$Freeze.stop()
	playerCaught = true
	$Freeze.start()
	$Siren.stop()
	$PowerMode.stop()
	$Retreat.stop()
	emit_signal("LostLife")


func _on_Freeze_timeout():
	freeze = false
	if playerCaught:
		$Player.die()
	else:
		$Dots.get_node('BlueTimer').paused = false
		$Dots.get_node('FlashingTimer').paused = false
	
func checkExtraLife(val):
	untilExtraLife -= val
	if untilExtraLife <=0:
		emit_signal("ExtraLife")
		untilExtraLife += extraLifeTresh

func _on_Dots_PacDotEaten():
	score += 10
	checkExtraLife(10)

func _on_Dots_PowerPelletEaten():
	$ModeTimer.paused = true
	score += 50
	checkExtraLife(50)
	
#func _on_Bonus_area_entered(area):
#	score += 100
#	checkExtraLife(100)
	
func fruitEaten(bonus):
	score += bonus
	checkExtraLife(bonus)
	
func ghostEaten():
	var bonus = get_node("Dots").getGhostBonus()
	score += bonus
	checkExtraLife(bonus)
	return bonus

func _on_ClassicMaze_StartLife():
	if gameOver:
		$AllGhosts.hide()
		$Player.hide()
	else:
		$AllGhosts.show()
		$Player.getReady()
		$ReadyTimer.start()
	mazeCompleted = false
	if is_instance_valid(fruit):
		fruit.destroy()
	$Siren.stop()
	$PowerMode.stop()
	$ModeTimer.stop()
	$Retreat.stop()

func _on_ClassicMaze_BeginGameplay():
	if !gameOver:
		$Player.startMoving()
		$Siren.play()
		modeTime = 0
		chaseMode = false
		$ModeTimer.wait_time = modeTimes[modeTime]
		$ModeTimer.paused = false
		$ModeTimer.start()

func _on_ReadyTimer_timeout():
	emit_signal("BeginGameplay")

func _on_Player_TryAgain():
	playerCaught = false
	emit_signal("StartLife")

func _on_Dots_SpawnFruit():
	# TEMP FRUIT SPAWN
	fruit = fruit_scene.instance()
	fruit.position = $FruitTarget.position
	fruit.changeSymbol(symbol)
	add_child(fruit)

func _on_Dots_Finished():
	mazeCompleted = true
	updateStage(stage+1)
	elroy = 0
	$Freeze.stop()
	$Siren.stop()
	$PowerMode.stop()
	$Retreat.stop()
	$Player.finish()
	$MazeWon.start()
	
func flashWhite():
	# White
	for tile in get_used_cells():
		var id = get_cellv(tile)
		if id != 90:
			set_cellv(tile, id + 45)

func flashBlue():
	# Blue / normal
	for tile in get_used_cells():
		var id = get_cellv(tile)
		if id != 90:
			set_cellv(tile, id - 45)

func _on_MazeWon_timeout():
	$AllGhosts.hide()
	for i in range(4):
		flashWhite()
		$MazeFlash.start()
		yield($MazeFlash, "timeout")
		flashBlue()
		$MazeFlash.start()
		yield($MazeFlash, "timeout")
	# TEMPORARY
	# Load in new mazes instead
	$Dots.resetAllDots()
	emit_signal("NewStage")
	emit_signal("StartLife")

func _on_ModeTimer_timeout():
	modeTime += 1
	if modeTime < modeTimes.size() && !playerCaught: # not done changing modes
		#change modes
		$ModeTimer.wait_time = modeTimes[modeTime]
		chaseMode = !chaseMode
		$ModeTimer.start()
		emit_signal("ChangeMode")

func _on_FlashingTimer_timeout():
	$ModeTimer.paused = false

func _on_Dots_Elroy1():
	elroy = 1
	
func _on_Dots_Elroy2():
	elroy = 2
	
func _on_HUD_GameOver():
	gameOver = true
	$Dots.hidePowerPellets()
	$GameOverTimer.start()

func _on_GameOverTimer_timeout():
	get_tree().change_scene("res://TitleScene.tscn")

# Called when the node enters the scene tree for the first time.
func updateStage(newStage):
	stage = newStage
	match stage:
		0:
			playerSpeed = maxSpeed * 0.8
			ghostSpeed = maxSpeed * .75
			tunnelSpeed = maxSpeed * 0.40
			$Dots.elroyThresh1 = 20
			elroy1Speed = maxSpeed * .80
			$Dots.elroyThresh2 = 10
			elroy2Speed = maxSpeed * .85
			powerSpeed = maxSpeed * .90
			blueSpeed = maxSpeed * .50
			frightTime = 6.0
			flashNumber = 5
			symbol = 0
			modeTimes = [7.0,20.0,7.0,20.0,5.0,20.0,5.0]
			$AllGhosts.threshold = [0,30,60,0]
		1:
			ghostSpeed = maxSpeed * .85
			playerSpeed = maxSpeed * 0.9
			tunnelSpeed = maxSpeed * 0.45
			$Dots.elroyThresh1 = 30
			elroy1Speed = maxSpeed * .90
			$Dots.elroyThresh2 = 15
			elroy2Speed = maxSpeed * .95
			powerSpeed = maxSpeed * .95
			blueSpeed = maxSpeed * .55
			frightTime = 5.0
			symbol = 1
			modeTimes = [7.0,20.0,7.0,20.0,5.0,1033.0,0.0166]
			$AllGhosts.threshold = [0,0,50,0]
		2:
			$Dots.elroyThresh1 = 40
			$Dots.elroyThresh2 = 20
			frightTime = 4.0
			symbol = 2
			$AllGhosts.threshold = [0,0,0,0]
		3:
			frightTime = 3.0
		4:
			playerSpeed = maxSpeed * 1.0
			ghostSpeed = maxSpeed * .95
			tunnelSpeed = maxSpeed * 0.50
			elroy1Speed = maxSpeed * 1
			elroy2Speed = maxSpeed * 1.05
			blueSpeed = maxSpeed * .60
			frightTime = 2.0
			symbol = 3
			modeTimes = [5.0,20.0,5.0,20.0,5.0,1037.0,0.0166]
		5:
			$Dots.elroyThresh2 = 25
			frightTime = 5.0
		6:
			$Dots.elroyThresh1 = 50
			frightTime = 2.0
			symbol = 4
		7:
			frightTime = 2.0
		8:
			$Dots.elroyThresh1 = 60
			$Dots.elroyThresh2 = 30
			frightTime = 1.0
			flashNumber = 3
			symbol = 5
		9:
			frightTime = 5.0
			flashNumber = 5
		10:
			frightTime = 2.0
			symbol = 6
		11:
			$Dots.elroyThresh1 = 80
			$Dots.elroyThresh2 = 40
			frightTime = 1.0
			flashNumber = 3
		12:
			frightTime = 1.0
			symbol = 7
		13:
			frightTime = 3.0
			flashNumber = 5
		14:
			$Dots.elroyThresh2 = 50
			frightTime = 1.0
			flashNumber = 3
		15:
			$Dots.elroyThresh1 = 100
		16:
			pass
		17:
			pass
		18:
			$Dots.elroyThresh2 = 60
		19:
			$Dots.elroyThresh1 = 120
		20:
			pass
		21:
			playerSpeed = maxSpeed * 0.9
