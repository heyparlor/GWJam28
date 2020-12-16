extends Spatial

# declare variables
onready var segmentNode = preload("res://Framework/Classes/NewSnake/Segment.tscn");
onready var cameraNode = preload("res://Framework/Classes/Camera/Camera.tscn");
onready var eggNode = preload("res://Framework/Classes/EggPickup/EggPickup.tscn");
var snake : Array = [];
var snake_segment : Array = []
var pos_start : Vector3 = Vector3();
var size_segment_radius = 0.5;
var segment_spacing = {min=0.5, max=0.75}
var num_segments : int = 15;
var dt : int = 15

var gravity : int = 20;
var speed : int = 5;
var egg_timer : float = 0
var camera
var camera_angle : float = 0

var has_egg : bool = false
var in_belly : bool = false
# this variable stores which segment in which the egg sits
var egg_belly : int = 3

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
				snake_segment[n].get_node("head").show()
				snake_segment[n].get_node("body").hide()
				snake_segment[n].name = "Head"
			add_child(snake_segment[n])
			# set the position of the new segment based on the old one
#			var pos_n = Vector3(pos_start.x+size_segment_radius * n, pos_start.y, pos_start.z+size_segment_radius * n)
			var pos_n = Vector3(pos_start.x, pos_start.y, pos_start.z)
			# store details for this segment in the snake array
			snake.append({pos = pos_n, pos_old = pos_n, velocity = Vector3(), gravity_vec = Vector3(), joint = true, rot = Vector3() })
			snake_segment[n].transform.origin = snake[n].pos
		
	# add the Camera to the first segment
	camera = cameraNode.instance()
	snake_segment[0].add_child(camera)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if has_egg:
		if not in_belly:
			var collider = snake_segment[egg_belly].get_node("CollisionShape")
			var mesh = snake_segment[egg_belly].get_node("MeshInstance")
			var body = snake_segment[egg_belly].get_node("body")
			collider.shape.radius = 1
			body.scale = Vector3(1,1,1)
			mesh.mesh.radius = 1
			mesh.mesh.height = 2
			in_belly = true
		else:
			if Input.is_action_just_released("throw_up"):
				var egg = eggNode.instance()
				egg.global_transform.origin = snake_segment[0].global_transform.origin
				owner.add_child(egg)
				has_egg = false
				in_belly = false
				egg_timer = 5.0
				var collider = snake_segment[egg_belly].get_node("CollisionShape")
				var mesh = snake_segment[egg_belly].get_node("MeshInstance")
				var body = snake_segment[egg_belly].get_node("body")
				collider.shape.radius = .5
				body.scale = Vector3(.5,.5,.5)
				mesh.mesh.radius = .5
				mesh.mesh.height = 1
		
	if egg_timer > 0:
		egg_timer -= delta
	else:
		egg_timer = 0
		
#####################################################
## Camera Swivel	
#####################################################

	if Input.is_action_just_pressed("swivel_left"):
		camera_angle += 1.5708
#		camera.rotation.y += 1 * delta
	if Input.is_action_just_pressed("swivel_right"):
		camera_angle -= 1.5708
#		camera.rotation.y -= 1 * delta

	camera.rotation.y = lerp(camera.rotation.y, camera_angle, delta * 3)

	
#####################################################
## Movement		
#####################################################
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
				if Input.is_action_pressed("move_north"):
					direction -= camera.transform.basis.z
#					direction -= snake_segment[n].transform.basis.z
				if Input.is_action_pressed("move_south"):
					direction += camera.transform.basis.z
				if Input.is_action_pressed("move_west"):
					direction -= camera.transform.basis.x
				if Input.is_action_pressed("move_east"):
					direction += camera.transform.basis.x

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
			
			if abs(snake[n].velocity.x) > 0.1 or abs(snake[n].velocity.z) > 0.1:
				var look = snake_segment[n].transform.origin - snake[n].velocity
				look.y += snake[n].velocity.y
				snake_segment[n].get_node("MeshInstance").look_at(look, Vector3.UP)
				
			var finalRot = snake_segment[n].get_node("MeshInstance").rotation_degrees
			finalRot.x = 45
			finalRot.z = 0
			snake_segment[n].get_node("head").rotation_degrees = lerp(snake_segment[n].get_node("head").rotation_degrees, finalRot, delta*10)
			snake_segment[n].get_node("body").rotation_degrees = snake_segment[n].get_node("head").rotation_degrees
			# prevent movement if we get stuck (egg in belly)
			if n < num_segments-1:
				if distance_tail > segment_spacing.max+1.0:
					snake[n].velocity = direction_tail * speed * 4
				
#			print( snake_segment[n].get_node("head").rotation_degrees )	
					
			snake_segment[n].move_and_slide(snake[n].velocity, Vector3.UP, false, 1, 1.4, false)
			
			snake[n].pos = snake_segment[n].global_transform.origin
			
			
func _on_Area_body_entered(body):
	if body.name == "EggPickup":
		# I added a cooldown timer here so the egg isn't picked up immediately 
		# after the snake throws it up
		if egg_timer == 0:
			print('got the egg')
			has_egg = true
			body.queue_free()
#
