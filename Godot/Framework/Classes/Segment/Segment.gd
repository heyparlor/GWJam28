extends  KinematicBody


# declare some variables on initialize
# these are usually either excplicitly declared (an integer, for example)
# or they are left null for later
# the : XXX is used to tell godot which type of variable this is
# it's optional to add it, but allegedly it makes the code perform a bit better
var gravity : int = 20
var segment_distance : float = 0.25

var head : KinematicBody
var index : int
var direction : Vector3 = Vector3()
var velocity : Vector3 = Vector3()
var gravity_vec : Vector3 = Vector3()

var scale_percent : float = 1
var new_scale_col : Vector3
var new_scale_pixel : Vector3
var prev_distance : float
var parent
var child

var set_egg : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("Segments")
	var collider = $CollisionShape
	collider.shape = collider.shape.duplicate()
	
	
	
	index = get_index()
	parent = get_parent().get_child(index-1)
	child = get_parent().get_child(index+1)
	new_scale_col = ( parent.get_node("CollisionShape").get_shape().get_extents() )*.96
	new_scale_pixel = parent.get_node("Sprite3D").scale*.96
	scale_percent *= .96
	
#	if name == "Segment8" and head.has_egg:
#		$CollisionShape.scale = Vector3(2,2,2)
#		$CollisionShape.translation.y = 0.5
#		$Sprite3D.pixel_size = 0.015
#		$Sprite3D.offset.y = 5
#	else:
	get_node("CollisionShape").get_shape().set_extents(new_scale_col)
#	get_node("CollisionShape").get_shape().set_height(new_scale_col*2)
	get_node("Sprite3D").scale = new_scale_pixel

	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	head = get_tree().get_nodes_in_group("Head")[0]
	if name == "Segment8" and owner.has_egg and not set_egg:
		print('okay')
		get_node("CollisionShape").get_shape().extents = Vector3(1,1,1)
		$CollisionShape.translation.y = 1
		$Sprite3D.pixel_size = 0.02
		$Sprite3D.offset.y = 5
		set_egg = true
	
	 # only run the gravity calculation if we're not on the floor
	if not is_on_floor():
		gravity_vec += Vector3.DOWN * gravity * delta
	else:
		# if we are on the ground, gravity will be perpendicular to the floor
		# this helps the player stay on slopes without sliding down
		# and we probably shouldn't use it for the egg 
		# (no else statement here)
		gravity_vec = -get_floor_normal() * gravity * delta
	# add the gravity to the velocity
	velocity.y = gravity_vec.y

	var distance = global_transform.origin.distance_to(parent.global_transform.origin)
	direction = Vector3()
	
	direction = (parent.global_transform.origin - self.global_transform.origin).normalized()
	var cardinal : Vector2 = Vector2( sign(direction.x), sign(direction.z) )
	
	var speed : float = 500 * distance
	
#	if child:
#		var c_distance = global_transform.origin.distance_to(child.global_transform.origin)
#		if c_distance > 1:
#			speed = 0
#			if not self in get_parent().locked_segments: 
#				get_parent().locked_segments.append(self)
			
	prev_distance = distance
	

	direction = direction * speed * delta	
	velocity.z = direction.z
	velocity.x = direction.x
	
	var c_distance : float = 0
	if child:
		
		var c_direction = (child.global_transform.origin - self.global_transform.origin).normalized()
		velocity += c_direction * speed * delta * 0.025
		c_distance = global_transform.origin.distance_to(child.global_transform.origin-velocity*delta*2.0)
	
	if c_distance < 1:
		move_and_slide(velocity, Vector3.UP, false, 1, 1.4, false)
	else:
		var c_direction = (child.global_transform.origin - self.global_transform.origin).normalized()
		
		velocity.x = c_direction.x * speed * delta
		velocity.z = c_direction.z * speed * delta

		move_and_slide(velocity, Vector3.UP, false, 1, 1.4, false)
#	if distance >= .75 * scale_percent:
#
#		var old_pos = translation
#		var target_pos = global_transform.origin.linear_interpolate(parent.global_transform.origin, delta *16.0)
#		move_and_slide(target_pos, Vector3.UP, false, 4, 1.4, false)
#	else:
#		if distance >= .5 * scale_percent:
#			var old_pos = global_transform.origin
#			var target_pos = global_transform.origin.linear_interpolate(parent.global_transform.origin, delta *16.0)
#			move_and_slide(target_pos, Vector3.UP, false, 4, 1.4, false)
#			move_and_slide(velocity, Vector3.UP, false, 4, 1.4, false)
	
	
#	if abs(distance) > segment_distance:
#		direction = (parent.global_transform.origin - self.global_transform.origin).normalized() * 200 * delta
#
#		self.global_transform.origin = parent.global_transform.origin
#	velocity.z = direction.z
#	velocity.x = direction.x




	# this function takes the velocity vector and applies it to the object's position
	# if a collision happens, the object will slide along the collision instead
	# (linear_velocity: Vector3, up_direction: Vector3 = Vector3( 0, 0, 0 ), stop_on_slope: bool = false, max_slides: int = 4, floor_max_angle: float = 0.785398, infinite_inertia: bool = true)

	
