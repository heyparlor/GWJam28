extends Spatial

var levels : Array = [
	preload("res://Assets/Rooms/L1.tscn"),
	preload("res://Assets/Rooms/L2.tscn"),
	preload("res://Assets/Rooms/L3.tscn"),
]

var current_level : int = 0

var level_data

var level_exit : Area 

# Called when the node enters the scene tree for the first time.
func _ready():
	load_level(current_level)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Area_body_entered(body):
	if body.name == "Head":
		print('okay')
		if current_level < levels.size()-1:
			current_level += 1
			load_level(current_level)


func load_level(level):
	if level_data: level_data.queue_free()
	level_data = levels[current_level].instance()
	add_child(level_data)
	level_exit = level_data.get_node("Area")
	level_exit.connect("body_entered", self,"_on_Area_body_entered")
