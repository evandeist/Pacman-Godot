extends AudioStreamPlayer

func _on_Wa_finished():
	queue_free()
