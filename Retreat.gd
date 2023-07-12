extends AudioStreamPlayer

func _on_AllGhosts_Retreat():
	self.play()

func _on_AllGhosts_noRetreat():
	self.stop()

func _process(delta):
	if get_parent().playerCaught:
		self.playing = false
