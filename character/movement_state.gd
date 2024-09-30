extends BaseState

## Body to apply nudge force
@export var physics_target: RigidBody3D
@export var pose_skeleton: Skeleton3D

@export var camera_arm: SpringArm3D

@export var animation_tree: AnimationTree

var smooth_velocity = Vector3()

func enter(args):
	animation_tree.set("parameters/Transition/transition_request", "movement")

func _process(delta: float) -> void:
	var is_triggered = ["backward", "forward", "left", "right"] \
		.map(func(i): return Input.is_action_just_pressed(i)) \
		.any(func(v): return v)
	
	if is_triggered:
		transition.emit(self, "movement", {})

func physics_update(delta) -> void:
	var left = -1 if Input.is_action_pressed("left") else 1 if Input.is_action_pressed("right") else 0
	var forward = -1 if Input.is_action_pressed("backward") else 1 if Input.is_action_pressed("forward") else 0

	var direction = Vector2(left, forward)
	
	if Input.is_action_pressed("shift"):
		direction *= 2
		
	smooth_velocity = smooth_velocity.move_toward(physics_target.quaternion.inverse() * physics_target.linear_velocity, 0.1)
		
	apply_movement_anim(direction, delta)
	rotate_skeleton(direction)
	apply_nudge(direction)


func apply_movement_anim(movement_vector: Vector2, delta):
	var dirmod = 1 if not movement_vector.y else sign(movement_vector.y)
	
	# TODO: make animation tree a blend2 again
	var old_anim_value = animation_tree.get("parameters/movement_speed/blend_position")
	animation_tree.set("parameters/movement_speed/blend_position", move_toward(old_anim_value, movement_vector.length() * dirmod, 4 * delta))

func apply_nudge(movement_vector: Vector2):
	if movement_vector:
		# Apply small force in target dir
		var force = Vector3(-movement_vector.x, 0, movement_vector.y).normalized() * 10
		physics_target.apply_central_force(force.rotated(Vector3.UP, pose_skeleton.rotation.y))

func rotate_skeleton(movement_vector: Vector2):
	# Rotate target skelly, mirrored when reversing
	pose_skeleton.rotation.x = 0
	pose_skeleton.rotation.z = 0
	pose_skeleton.rotation.y = camera_arm.rotation.y
	
	var rotated_vel = smooth_velocity
	
	var xvel_diff = clamp(rotated_vel.x, -3.0, 3.0) / 3.0
	
	var rotation_radians_z = xvel_diff * PI / 10.0
	
	#pose_skeleton.rotate(pose_skeleton.transform.basis.x.normalized(), rotation_radians_x)
	pose_skeleton.rotate(pose_skeleton.transform.basis.z.normalized(), rotation_radians_z)
	
	if movement_vector:
		var adj = Vector2(movement_vector.x, abs(movement_vector.y))
		if movement_vector.y < 0:
			adj.x = -adj.x
		
		pose_skeleton.rotate_y(adj.angle() - PI / 2)
	
