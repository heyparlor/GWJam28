extends Node

var gravity : int = 20
var speed : int = 500

var direction : Vector3 = Vector3()
var velocity : Vector3 = Vector3()
var gravity_vec : Vector3 = Vector3()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	if Input.is_action_pressed("ui_up"):
		direction -= $Segment.transform.basis.z
	if Input.is_action_pressed("ui_down"):
		direction += $Segment.transform.basis.z
	if Input.is_action_pressed("ui_left"):
		direction -= $Segment.transform.basis.x
	if Input.is_action_pressed("ui_right"):
		direction += $Segment.transform.basis.x
		
	velocity.x = direction.x * delta
	velocity.z = direction.z * delta
	
	$Segment.translation += velocity * delta
	
#	$Segment.move_and_slide(velocity, Vector3.UP, false, 1, 1.4, false)
