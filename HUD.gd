extends Node2D

signal GameOver
var currentMaze
var stageNumber = 1
var player1Score = 00
var lostLife = false

func _ready():
	$GameOver.hide()
	currentMaze = get_owner().get_node("ClassicMaze")
	$PlayerOne.hide()
	$Score.startFlash()

func _process(delta):
	player1Score = currentMaze.score
	$Score.printPoints(player1Score)

func _on_ClassicMaze_StartLife():
	if $Lives.extraLives < 0:
		emit_signal("GameOver")
		$GameOver.show()
	else:
		$Lives.drawLives()
		$Ready.show()
	$Stage.updateStage(stageNumber)

func _on_ClassicMaze_BeginGameplay():
	$Ready.hide()

func _on_ClassicMaze_NewStage():
	stageNumber += 1

func _on_ClassicMaze_LostLife():
	$Lives.loseLife()

func _on_ClassicMaze_ExtraLife():
	$Lives.extraLife()
