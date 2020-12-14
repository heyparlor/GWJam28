extends Node


# declare some variables on initialize
# these are usually either excplicitly declared (an integer, for example)
# or they are left null for later
# the : XXX is used to tell godot which type of variable this is
# it's optional to add it, but allegedly it makes the code perform a bit better
var gravity : int = 20
var speed : int = 500

var direction : Vector3 = Vector3()
var velocity : Vector3 = Vector3()
var gravity_vec : Vector3 = Vector3()

var has_egg : bool = false

var index
var child

var locked_segments : Array = []

# load in the graphics for the player head


# the onready thing here tells godot to set this variable up once the
# entire scene has been loaded in. You can't get children of a scene
# until it's all in there.
# this is the same as setting up an empty variable here and assigning
# it in the _ready function below (just cleaner to do it here if you can)
# $XXXX can be used to access children from the node on which
# your script is attached. You can also use get_node("XXXX") to do the same thing
onready var head : KinematicBody = $Head

# Called when the node enters the scene tree for the first time.
func _ready():
	$Head.add_to_group("Head")
	index = head.get_index()
	child = get_child(index+1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	
	if has_egg:
		var placement = $Segment8.get_node("CollisionShape").global_transform.origin
		$Head/Egg.global_transform.origin = placement
		$Head/Egg.translation.y += 1
	# we'll put the main player controls in here
	# but we want to apply the movement to the head segment
	# so we'll use "head." before any functions that should directly affect it
	
	# delta is the time between this frame and the last frame.
	# we use it when moving things around to keep movement consistent
	# if the framerate drops.
	
	# only run the gravity calculation if we're not on the floor
	if not head.is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
	else:
		# if we are on the ground, gravity will be perpendicular to the floor
		# this helps the player stay on slopes without sliding down
		# and we probably shouldn't use it for the egg 
		# (no else statement here)
		gravity_vec = -head.get_floor_normal() * gravity * delta
		
	# set the gravity velocity to the gravity vector
	velocity.y = gravity_vec.y
	
	direction = Vector3()
	
	var cardinal : Vector2 = Vector2()
	
	if Input.is_action_pressed("ui_up"):
		direction -= head.transform.basis.z
		cardinal.y = -1
	if Input.is_action_pressed("ui_down"):
		direction += head.transform.basis.z
		cardinal.y = 1
	if Input.is_action_pressed("ui_left"):
		direction -= head.transform.basis.x
		cardinal.x = -1
	if Input.is_action_pressed("ui_right"):
		direction += head.transform.basis.x
		cardinal.x = 1
	# lets figure out which sprite to draw
	match cardinal:
		Vector2(0,-1):
			head.get_node("Sprite3D").frame = 4
		Vector2(0,1):
			head.get_node("Sprite3D").frame = 0
		Vector2(-1,0):
			head.get_node("Sprite3D").frame = 6
		Vector2(1,0):
			head.get_node("Sprite3D").frame = 2
		Vector2(1,-1):
			head.get_node("Sprite3D").frame = 3
		Vector2(1,1):
			head.get_node("Sprite3D").frame = 1
		Vector2(-1,-1):
			head.get_node("Sprite3D").frame = 5
		Vector2(-1,1):
			head.get_node("Sprite3D").frame = 7
				
	var speed : float = 300
	
#	if child:
#		var c_distance = head.global_transform.origin.distance_to(child.global_transform.origin)
#		if c_distance > 1:
#			speed = 0
#			if not self in locked_segments: 
#				locked_segments.append(head)
		
	direction = direction.normalized() * speed * delta	
	
	
#	if head in locked_segments: 
#
#		direction = (head.global_transform.origin - child.global_transform.origin).normalized()
#		direction = direction * speed * delta	
#		velocity.z = direction.z
#		velocity.x = direction.x
#
#		head.move_and_slide(velocity, Vector3.UP, false, 1, 1.4, false)
#
#		var c_distance = head.global_transform.origin.distance_to(child.global_transform.origin)
#		if c_distance < 0.5:
#			locked_segments.erase(head)
#	else:
		
	velocity.z = direction.z
	velocity.x = direction.x
	
	# this function takes the velocity vector and applies it to the object's position
	# if a collision happens, the object will slide along the collision instead
	# (linear_velocity: Vector3, up_direction: Vector3 = Vector3( 0, 0, 0 ), stop_on_slope: bool = false, max_slides: int = 4, floor_max_angle: float = 0.785398, infinite_inertia: bool = true)
#	head.move_and_slide(velocity)
	
	var c_distance : float = 0
	if child:
		var c_direction = (child.global_transform.origin - head.global_transform.origin).normalized()
		
		velocity += c_direction * speed * delta * 0.025
		
		c_distance = head.global_transform.origin.distance_to(child.global_transform.origin-velocity*delta*2.0)
	
	if c_distance < 1:
		head.move_and_slide(velocity, Vector3.UP, false, 1, 1.4, false)
	else:
		var c_direction = (child.global_transform.origin - head.global_transform.origin).normalized()
		
		velocity.x = c_direction.x * speed * delta
		velocity.z = c_direction.z * speed * delta

		head.move_and_slide(velocity, Vector3.UP, false, 1, 1.4, false)


func _on_Area_body_entered(body):
	if body.name == "EggPickup":
		print('okay')
		has_egg = true
		$Head/Egg.disabled = false
		body.queue_free()
