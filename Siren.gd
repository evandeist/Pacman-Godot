extends AudioStreamPlayer

var sirenLevel = 1

func _on_Dots_PowerPelletEaten():
	self.stop()
	
func _on_FlashingTimer_timeout():
	self.play()

func _on_Dots_sirenChange():
	sirenLevel += 1
	var wasPlaying = self.playing
	stream = load("res://Sounds/Mobile - Pac-Man iPod - Sound Effects/siren" + str(sirenLevel) + ".wav")
	if wasPlaying:
		self.play()	

func _on_ClassicMaze_NewStage():
	sirenLevel = 1
	stream = load("res://Sounds/Mobile - Pac-Man iPod - Sound Effects/siren1.wav")

func _on_Dots_ShutUp():
	self.stop()

func _process(delta):
	if get_parent().get_node("PowerMode").playing:
		self.playing = false
	
	if get_parent().playerCaught:
		self.playing = false
