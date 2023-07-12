extends Node2D

# instantiates when instructed to by the maze
# starts timer once instantiated to self-destruct
# Detects for player collision. On collision:
#  play sound
#  cancel fruit display timer
#  show bonus score, activate timer for bonus score
#  hide fruit sprite after 2 frames
#  when bonus score is done displaying, destroy this instance



var framesSinceEaten = -1
var points = 100
var symbol = 0

func _ready():
	#connect("area_entered", get_parent(), "_on_Bonus_area_entered")
	var rng = RandomNumberGenerator.new()
	
	$ScoreBonus.play(str(points))
	$ScoreBonus.hide()
	
	$FruitDisplay.wait_time = rng.randf_range(9.0,10.0)
	$FruitDisplay.start()
	

func _process(delta):
	if framesSinceEaten >=0:
		framesSinceEaten += 1
		if framesSinceEaten > 2: # cringe
			$Fruit.hide()

func _on_FruitDisplay_timeout():
	queue_free()

func _on_BonusDisplay_timeout():
	queue_free()

func destroy():
	queue_free()

func changeSymbol(sym):
	symbol = sym
	match symbol:
		0:
			$Fruit.play("Cherries")
			points = 100
		1:
			$Fruit.play("Strawberry")
			points = 300
		2:
			$Fruit.play("Orange")
			points = 500
		3:
			$Fruit.play("Apple")
			points = 700
		4:
			$Fruit.play("Melon")
			points = 1000
		5:
			$Fruit.play("Galaxian")
			points = 2000
		6:
			$Fruit.play("Bell")
			points = 3000
		7:
			$Fruit.play("Key")
			points = 5000


func _on_Bonus_area_entered(area):
	if framesSinceEaten > -1: # stupid fix idk why disabling collision doesnt work
		return
	get_parent().fruitEaten(points)
	framesSinceEaten = 0
	$CollisionShape2D.disabled = true
	$FruitSound.play()
	$FruitDisplay.stop()
	$BonusDisplay.start()
	$ScoreBonus.show()
