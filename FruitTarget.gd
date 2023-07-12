extends Node2D

export(PackedScene) var fruit_scene
signal FruitEaten

func _on_Dots_SpawnFruit():
	add_child(fruit_scene.instance())
	
func fruitEaten():
	emit_signal("FruitEaten")
