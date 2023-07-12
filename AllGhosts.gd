extends Node2D

signal Retreat
signal noRetreat

var ghosts
var oneRetreating
var Dots
var begin = false
#TODO thresholds can change
enum houseGhosts {PINKY, INKY, CLYDE, DONE}
var nextGhost = houseGhosts.PINKY

var ghostCounter = [0,0,0,0]
var threshold = [0,30,60,0]
var globalThreshold = [7,17,32,0]
var globalCounter = 0
var globalMode = false

var animFrame = 0

func _ready():
	ghosts = get_children()
	Dots = get_owner().get_node('Dots')
			
func isOneRetreating():
	for g in ghosts:
		if g.state == 6 || g.state == 8: # EYES or RESPAWNING
			return true
	return false
	
func _process(delta):
	if begin:
		if globalMode && globalCounter == globalThreshold[nextGhost]:
				if globalCounter == 32: # clyde case
					if get_node("Clyde").state == 0: # Waiting in the house
						globalMode = false
				else:
					spawnGhost()
		elif !globalMode && ghostCounter[nextGhost] == threshold[nextGhost]:
				spawnGhost()
	if oneRetreating:
		if !isOneRetreating():
			oneRetreating = false
			# stop the retreating sound
			emit_signal("noRetreat")
	else:
		if isOneRetreating():
			oneRetreating = true
			# play retreat sound
			emit_signal("Retreat")
			
	# frame of animation for ghosts:
	#TODO: LET EACH GHOST ANIMATE THEMSELVES THROUGH ENGINE SINGLETON
	#animFrame = wrapi(animFrame + 1, 0, 15)
	#ghostAnim()

func ghostAnim():
	for g in ghosts:
		# match with current animation
		var sprite = g.get_node("AnimatedSprite")
		var anim = sprite.animation
		if (anim == "FaceDown") || (anim == "FaceUp") || \
			(anim == "FaceLeft") || (anim == "FaceRight") || \
			(anim == "TURN-TO-BLUE"):
				if animFrame < 	7:
					sprite.frame = 0
				else:
					sprite.frame = 1
		elif (anim == "FlashWhite"):
			if animFrame < 3:
				sprite.frame = 0
			elif animFrame < 7:
				sprite.frame = 1
			elif animFrame < 11:
				sprite.frame = 2
			else:
				sprite.frame = 3

func _on_ClassicMaze_StartLife():
	#nextGhost = houseGhosts.PINKY
	#globalCounter = 0
	for g in ghosts:
		g.restart()

func _on_ClassicMaze_BeginGameplay():
	nextGhost = houseGhosts.PINKY
	globalCounter = 0
	for g in ghosts:
		g.go()
		
func _on_Freeze_timeout():
	if get_owner().playerCaught:
		for g in ghosts:
			g.hide()

func _on_DotTimer_timeout():
	# extra condition?
	spawnGhost()

func spawnGhost():
	match nextGhost:
		houseGhosts.PINKY:
			get_node("Pinky").spawnIn()
		houseGhosts.INKY:
			get_node("Inky").spawnIn()
		houseGhosts.CLYDE:
			get_node("Clyde").spawnIn()
	nextGhost = clamp(nextGhost+1, 0, 3)

func _on_Dots_IncreaseCounter():
	if globalMode:
		globalCounter += 1
	else:
		ghostCounter[nextGhost] += 1
		if ghostCounter[nextGhost] == threshold[nextGhost]:
			spawnGhost()

func _on_ReadyTimer_timeout():
	begin = true

func _on_ClassicMaze_ChangeMode():
	for g in ghosts:
		g.modeChangeFlag = true
		if g.state == g.states.WAITING || g.state == g.states.SPAWNING:
			print(" POOBY ")
			g.exitLeft = false

func _on_Player_TryAgain():
	globalMode = true

func _on_ClassicMaze_NewStage():
	globalMode = false
	ghostCounter = [0,0,0,0]
	nextGhost = houseGhosts.PINKY
