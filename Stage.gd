extends TileMap


const symbols = [0,1,2,2,3,3,4,4,5,5,6,6,7]

var startTile = get_used_cells()[0]

func updateStage(stageNumber):
	var symbol = -1
	for i in range(7):
		if i <= stageNumber-1:
			var d = stageNumber-7
			if d > 0:
				if i + d > symbols.size()-1:
					symbol = symbols[-1]
				else:
					symbol = symbols[i + d]
			else:
				symbol = symbols[i]
		else:
			symbol = -1
		set_cellv(startTile + (Vector2.LEFT*i), symbol)
	
