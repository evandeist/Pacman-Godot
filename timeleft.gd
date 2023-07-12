extends Label

var maze 

# Called when the node enters the scene tree for the first time.
func _ready():
	maze = get_parent()

func _process(delta):
	self.text = str(maze.get_node("ModeTimer").time_left)
