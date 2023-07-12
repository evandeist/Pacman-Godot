extends Label


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var maze 

# Called when the node enters the scene tree for the first time.
func _ready():
	maze = get_parent()

func _process(delta):
	if maze.chaseMode:
		self.text = "CHASE"
	else:
		self.text = "SCATTER"
