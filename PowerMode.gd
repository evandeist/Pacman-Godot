extends AudioStreamPlayer

func _on_AllGhosts_Retreat():
	self.stream_paused = true

func _on_AllGhosts_noRetreat():
	self.stream_paused = false
	
func _on_Dots_PowerPelletEaten():
	self.play()

func _on_FlashingTimer_timeout():
	self.stop()

func _process(delta):
	if get_parent().playerCaught:
		self.playing = false
