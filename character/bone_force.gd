extends Node

@export var target_forcer: RigidBody3D
@export var target_skeleton: Skeleton3D

@export var spring_stiffness: float = 1200.0
@export var max_linear_force: float = 9999.0

@export var max_angular_force: float = 9999.0

@export var anims: AnimationPlayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var accum_diff = 0.0
	
	for b in get_children():
		if b is not RigidBody3D or b.freeze or b.name.begins_with("i_"):
			continue
			
		var target_bone_id = target_skeleton.find_bone(b.name)
		
		var target_transform: Transform3D = target_skeleton.transform * target_skeleton.get_bone_global_pose(target_bone_id)
		var current_transform: Transform3D = b.transform
		var size = b.get_node("CSGBox3D").size

		var rotation_difference := target_transform.basis.get_rotation_quaternion() * current_transform.basis.get_rotation_quaternion().inverse()
		var position_difference:Vector3 = target_transform.origin - (current_transform.origin )
		
		accum_diff += clamp(target_transform.basis.get_rotation_quaternion().angle_to(current_transform.basis.get_rotation_quaternion()), 0, 1)
		
		#if position_difference.length_squared() > 1.0:
			#b.global_position = target_transform.origin
		#else:
		#var force: Vector3 = hookes_law(position_difference, b.linear_velocity, spring_stiffness, b.mass)
		#force = force.limit_length(max_linear_force) + position_difference
		#b.apply_force(force)
		
		#if not b.name == "mixamorig_Hips":
		#	target_forcer.apply_force(-force)
		var iner = PhysicsServer3D.body_get_direct_state(b.get_rid()).inverse_inertia.inverse()
	
		var position_factor = position_difference.length() * 3
		var normalized_rotation_angles = normalize_rotation(rotation_difference.get_euler())
		
		# need to zero out twist. It's causing super fast rotations caused by dampening going crazy
		var torque = hookes_law(normalized_rotation_angles * 4, b.angular_velocity, spring_stiffness * position_factor, iner) * iner
		torque = torque.limit_length(max_angular_force)
		# ACTUAL SLEEPY ROOT CAUSE
		# sometimes diff goes between positive radian and negative radian, that causes oscillation.
		# and sometimes dampening overcorrects hard. ne
				
		if b.name == "mixamorig_Hips":
			print("DIFF ", normalized_rotation_angles)
			
			#print("VELO ", b.angular_velocity)
			#print("INER ", iner)
			#print("FORC", torque)
		
		b.apply_torque(torque)
		#target_forcer.apply_torque(-torque)
	
	accum_diff /= get_child_count()
	
	#print(accum_diff)
	
	anims.speed_scale = clampf(1 - accum_diff, 0.1, 1)

func normalize_rotation(angles: Vector3) -> Vector3:
	return Vector3(
		normalize_angle(angles.x),
		normalize_angle(angles.y),
		normalize_angle(angles.z)
	)

func normalize_angle(angle: float) -> float:
	# Normalize the angle to be within the range [-PI, PI]
	if angle > PI:
		angle -= TAU  # TAU is 2 * PI
	if angle < -PI:
		angle += TAU
	return angle
	
#
func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, inertia: Vector3) -> Vector3:
	return stiffness * displacement - 2 * (Vector3(sqrt(inertia.x * stiffness ), sqrt(inertia.y * stiffness ), sqrt(inertia.z * stiffness )) * current_velocity)
	

#func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, mass: float) -> Vector3:
	#return stiffness * displacement - (80 * current_velocity)
	#
