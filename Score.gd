extends TileMap

var flash = false
var scoreOrigin = Vector2(6,1)
	
func printPoints(points):
	if points == 0: # 00
		set_cellv(scoreOrigin, 0)
		set_cellv(scoreOrigin + Vector2(-1, 0), 0)
		return
		
	var place = 0
	while points:
		var v = Vector2(scoreOrigin.x - place, scoreOrigin.y)
		set_cellv(v, points%10)
		set_cellv(v + Vector2(10,0), points%10) #TEMP HIGH SCORE
		points = points/10
		place += 1

func startFlash():
	get_node("1UPFlash").start()

func _on_1UPFlash_timeout():
	flash = !flash
	if flash:
		set_cellv(Vector2(3,0), 1)
		set_cellv(Vector2(4,0), 11)
		set_cellv(Vector2(5,0), 12)
	else:
		set_cellv(Vector2(3,0), -1)
		set_cellv(Vector2(4,0), -1)
		set_cellv(Vector2(5,0), -1)
	
	get_node("1UPFlash").start()
