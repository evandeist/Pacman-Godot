extends TileMap

signal PacDotEaten
signal PowerPelletEaten
signal IncreaseCounter
signal SpawnFruit
signal Finished
signal Elroy1
signal Elroy2
signal sirenChange
signal ShutUp

export(PackedScene) var WaSound
export(PackedScene) var KaSound

var ghostBonus = 200

var wa = true
var flash = false
var totalDots
var remainingDots
var powerPellets
var debug = 0
var elroyThresh1 = 20
var elroyThresh2 = 10
var sirenChanged = false

# Called when the node enters the scene tree for the first time.
func _ready():
	totalDots = get_used_cells().size() - get_used_cells_by_id(2).size()
	powerPellets = get_used_cells_by_id(1)
	remainingDots = totalDots
	
#Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func remainingDots():
	return remainingDots
	
func eatenDots():
	return totalDots - remainingDots
	
func eat(tile):
	emit_signal("IncreaseCounter")
	remainingDots -= 1
	
	if (eatenDots() == 70 || eatenDots() == 170):
		emit_signal("SpawnFruit")
	
	if(remainingDots == elroyThresh1): 
		emit_signal("Elroy1")
	if(remainingDots == elroyThresh2):
		emit_signal("Elroy2")
		
	if(remainingDots == int(totalDots*0.6)):
		emit_signal("sirenChange")
		sirenChanged = true
	if(remainingDots == int(totalDots*0.4)):
		emit_signal("sirenChange")
		sirenChanged = true
	if(remainingDots == int(totalDots*0.2)):
		emit_signal("sirenChange")
		sirenChanged = true
	if(remainingDots == int(totalDots*0.1)):
		emit_signal("sirenChange")
		sirenChanged = true
		
	if (remainingDots == 0 + debug*243):
		$BlueTimer.stop()
		$FlashingTimer.stop()
		emit_signal("Finished")
	
	$DotTimer.stop()
	$DotTimer.start()

	if get_cellv(tile) == 1 || get_cellv(tile) == 3:
		if remainingDots != 0:
			emit_signal("PowerPelletEaten")
			if sirenChanged:
				emit_signal("ShutUp")
			$BlueTimer.stop()
			$FlashingTimer.stop()
			$BlueTimer.wait_time = get_parent().frightTime
			$BlueTimer.start()
	else:
		emit_signal("PacDotEaten")
		
	set_cellv(tile, 2) # eaten
	var sound
	if wa:
		#$Wa.play()
		sound = WaSound.instance()
		add_child(sound)
		sound.play()
		#$Waka.stream = load("res://Sounds/Pac-Man/munch_1.wav")
		#$Waka.play()
		
	else:
		sound = KaSound.instance()
		add_child(sound)
		sound.play()
		#$Waka.stream = load("res://Sounds/Pac-Man/munch_2.wav")
		#$Waka.play()
	wa = !wa
	sirenChanged = false


func _on_PowerPelletFlash_timeout():
	flash()
	flash = !flash
	$PowerPelletFlash.start()

func flash():
	if flash:
		for tile in get_used_cells_by_id(1):
			set_cellv(tile, 3)
	else:
		for tile in get_used_cells_by_id(3):
			set_cellv(tile, 1)

func _on_BlueTimer_timeout():
	var flashes = get_parent().flashNumber
	$FlashingTimer.wait_time = (((flashes-1)*14.0) + 11.0)/60.0
	$FlashingTimer.start()

func _on_Dots_PowerPelletEaten():
	ghostBonus = 200

func getGhostBonus():
	var ret = ghostBonus
	ghostBonus *= 2
	return ret

func resetAllDots():
	for tile in get_used_cells_by_id(2):
		set_cellv(tile, 0)
	totalDots = get_used_cells().size() - get_used_cells_by_id(2).size()
	for pp in powerPellets:
		set_cellv(pp, 3)
	remainingDots = totalDots

func _on_DotTimer_timeout():
	$DotTimer.stop()
	$DotTimer.start()

func _on_ClassicMaze_BeginGameplay():
	$DotTimer.stop()
	$DotTimer.start()
	flash = true
	flash()
	$PowerPelletFlash.start()
	
func _on_ClassicMaze_StartLife():
	$PowerPelletFlash.stop()
	flash = false
	flash()


func _on_ClassicMaze_LostLife():
	$DotTimer.stop()
	
func hidePowerPellets():
	$PowerPelletFlash.stop()	
	flash = true
	flash()
