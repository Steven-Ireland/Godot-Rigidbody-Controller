extends BaseState

## Body to apply nudge force
@export var physics_target: RigidBody3D
@export var pose_skeleton: Skeleton3D

@export var camera_arm: SpringArm3D

@export var animation_tree: AnimationTree

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
	pose_skeleton.rotation.y = camera_arm.rotation.y
	
	if movement_vector:
		var adj = Vector2(movement_vector.x, abs(movement_vector.y))
		if movement_vector.y < 0:
			adj.x = -adj.x
		
		pose_skeleton.rotate_y(adj.angle() - PI / 2)
	
