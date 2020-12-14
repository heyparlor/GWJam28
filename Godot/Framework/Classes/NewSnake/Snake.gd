extends Spatial

# declare variables
onready var segmentNode = preload("res://Framework/Classes/NewSnake/Segment.tscn");
onready var cameraNode = preload("res://Framework/Classes/Camera/Camera.tscn");
var snake : Array = [];
var snake_segment : Array = []
var pos_start : Vector3 = Vector3();
var size_segment_radius = 0.5;
var segment_spacing = {min=0.5, max=0.75}
var num_segments : int = 15;
var dt : int = 15

var gravity : int = 20;
var speed : int = 5;


var has_egg : bool = false
var in_belly : bool = false
# this variable stores which segment in which the egg sits
var egg_belly : int = 2

# Called when the node enters the scene tree for the first time.
func _ready():

	# loop through this code for each segment we want to add
	for n in range(num_segments):
		
		# instance a new segment, store it in the snake_segment array, and add it to the scene
		# since arrays & for loops begin at 0, we subtract one from the loop
		if n < num_segments: 
			snake_segment.append( segmentNode.instance() );
			snake_segment[n].set_collision_layer_bit(0, false)
			snake_segment[n].set_collision_layer_bit(1, true)
			var collider = snake_segment[n].get_node("CollisionShape")
			collider.shape = collider.shape.duplicate()
			var mesh = snake_segment[n].get_node("MeshInstance")
			mesh.mesh = mesh.mesh.duplicate()
			
################################################################################
# This was added for debug purposes and will put the egg
# into the snake's belly
#			
#			if n == 2:
#				collider.shape.radius = 1
#				mesh.mesh.radius = 1
#				mesh.mesh.height = 2
				
################################################################################
			
			# we'll want a collision area in the head to 
			# check if it's on an item
			if n == 0:
				snake_segment[n].get_node("Area").connect("body_entered", self,"_on_Area_body_entered")


			add_child(snake_segment[n])
			# set the position of the new segment based on the old one
			var pos_n = Vector3(pos_start.x+size_segment_radius * n, pos_start.y, pos_start.z+size_segment_radius * n)
			# store details for this segment in the snake array
			snake.append({pos = pos_n, pos_old = pos_n, velocity = Vector3(), gravity_vec = Vector3(), joint = true, rot = Vector3() })
			snake_segment[n].transform.origin = snake[n].pos
		
	# add the Camera
	var camera = cameraNode.instance()
	snake_segment[0].add_child(camera)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if has_egg and not in_belly:
		var collider = snake_segment[egg_belly].get_node("CollisionShape")
		var mesh = snake_segment[egg_belly].get_node("MeshInstance")
		collider.shape.radius = 1
		mesh.mesh.radius = 1
		mesh.mesh.height = 2
		in_belly = true
	# loop through our segments
	for n in range(num_segments):
		# keep the head attached to whatever (for testing)
		if n < num_segments: 
	
			snake[n].velocity = Vector3.ZERO
			
			# set up a few variables to establish spacial relationships between segments
			var distance_head : float = 0; var distance_tail : float = 0; var direction_head : Vector3; var direction_tail : Vector3;
			var angle_head : float = 0.0;
			if n != 0: 
				distance_head = (snake[n].pos).distance_to(snake[n-1].pos)
				direction_head = (snake[n].pos).direction_to(snake[n-1].pos)
				angle_head = (snake[n].pos).angle_to(snake[n-1].pos)
			if n < num_segments-1:
				distance_tail = (snake[n].pos).distance_to(snake[n+1].pos)
				direction_tail = (snake[n].pos).direction_to(snake[n+1].pos)
			
			# set the gravity velocity to the gravity vector
			snake[n].gravity_vec += Vector3.DOWN * gravity * delta
			snake[n].velocity.y = snake[n].gravity_vec.y
			if snake_segment[n].is_on_floor(): 
				snake[n].gravity_vec.y = 0
				snake[n].velocity.y = 0
			
			
			
			if n == 0:

				# this is the head
				var direction = Vector3()
				if Input.is_action_pressed("ui_up"):
					direction -= snake_segment[n].transform.basis.z
				if Input.is_action_pressed("ui_down"):
					direction += snake_segment[n].transform.basis.z
				if Input.is_action_pressed("ui_left"):
					direction -= snake_segment[n].transform.basis.x
				if Input.is_action_pressed("ui_right"):
					direction += snake_segment[n].transform.basis.x

				direction = direction.normalized()

				snake[n].velocity.x = direction.x * speed
				snake[n].velocity.z = direction.z * speed
			else:
#				print([distance_head, distance_tail, direction_head, direction_tail])
				
				if distance_head > segment_spacing.max:
					var mod : int = 2
					if n == 2: mod = 3
					snake[n].velocity.x = direction_head.x * speed*mod
					snake[n].velocity.z = direction_head.z * speed*mod
					if angle_head < 0.3:
						snake[n].gravity_vec.y = 0
						snake[n].velocity.y =  direction_head.y * speed*3

				elif distance_head <= segment_spacing.min:
					pass
#					snake[n].velocity.x = direction_head.x * speed*0.95
#					snake[n].velocity.z = direction_head.z * speed*0.95
				else:
					snake[n].velocity.x = direction_head.x * speed
					snake[n].velocity.z = direction_head.z * speed
			

			
			# prevent movement if we get stuck (egg in belly)
			if n < num_segments-1:
				if distance_tail > segment_spacing.max+1.0:
					snake[n].velocity = direction_tail * speed
					
				
			snake_segment[n].move_and_slide(snake[n].velocity, Vector3.UP, false, 1, 1.4, false)
			
			snake[n].pos = snake_segment[n].global_transform.origin
			
			
func _on_Area_body_entered(body):
	if body.name == "EggPickup":
		print('got the egg')
		has_egg = true
		body.queue_free()
#
