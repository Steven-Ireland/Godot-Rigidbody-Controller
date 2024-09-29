extends Node

@export var follow: RigidBody3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	$Skeleton3D.global_position = follow.global_position + Vector3(0, -1, 0);
	
	# todo: project along plane
	var projected: Vector3 = follow.linear_velocity.project(follow.transform.basis.z) / 10
	var a_sign = 1 if projected.angle_to(follow.transform.basis.z) == 0 else -1


func _process(delta: float) -> void:
	var left = -1 if Input.is_action_pressed("left") else 1 if Input.is_action_pressed("right") else 0
	var forward = -1 if Input.is_action_pressed("backward") else 1 if Input.is_action_pressed("forward") else 0

	var direction = Vector2(left, forward)
	
	if Input.is_action_pressed("shift"):
		direction *= 2
		
	var dirmod = 1 if not direction.y else sign(direction.y)

	# TODO: No blend, just need 8 way
	$Skeleton3D/AnimationTree.set("parameters/movement_speed/blend_position", direction.length() * dirmod)
	
	#$Skeleton3D.rotation.x = direction.length() * dirmod * PI / 16
	$Skeleton3D.rotation.y = get_parent().get_node("SpringArm3D").rotation.y
	
	if direction:
		# Apply small force in target dir
		var force = Vector3(-direction.x, 0, direction.y) * 10
		follow.apply_central_force(force.rotated(Vector3.UP, $Skeleton3D.rotation.y))
		
		# Rotate to account for backing up
		var adj = Vector2(direction.x, abs(direction.y))
		if direction.y < 0:
			adj.x = -adj.x
		
		$Skeleton3D.rotate_y(adj.angle() - PI / 2)
	
