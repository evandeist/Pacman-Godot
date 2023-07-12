extends TileMap

signal GameOver

var extraLives = 2
var maxLives = 3
var startTile = get_used_cells()[0]

func _ready():
	drawLives()

func extraLife():
	extraLives = clamp(extraLives+1, 0, 3)
	$ExtraPlay.play()
	drawLives()

func loseLife():
	extraLives -= 1
	
func drawLives():	
	for l in range(maxLives):
		var tile = startTile - Vector2(l,0)
		if l+1 <= extraLives:
			set_cellv(tile, 0)
		else:
			set_cellv(tile,-1)
