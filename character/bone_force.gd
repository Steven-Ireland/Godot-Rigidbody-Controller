extends Node

@export var target_forcer: RigidBody3D
@export var target_skeleton: Skeleton3D

@export var spring_stiffness: float = 1200.0
@export var max_angular_force: float = 9999.0

@export var anims: AnimationPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var accum_diff = 0.0
	
	for b in get_children():
		if b is not RigidBody3D or b.freeze or b.name.begins_with("i_"):
			continue
			
		var target_bone_id = target_skeleton.find_bone(b.name)
		
		var target_transform: Transform3D = target_skeleton.get_bone_global_pose(target_bone_id).rotated(Vector3.UP,target_skeleton.rotation.y)
		var current_transform: Transform3D = b.transform
		var rotation_difference := target_transform.basis.get_rotation_quaternion() * current_transform.basis.get_rotation_quaternion().inverse()
		
		var og_inertia = PhysicsServer3D.body_get_direct_state(b.get_rid()).inverse_inertia.inverse()
		var torque = hookes_law(rotation_difference.get_euler(), b.angular_velocity, spring_stiffness)
		
		# To apply inertia properly, rotate the proposed torque back to zero basis
		# Then apply inertia, which is centered only around xyz axes
		# Then rotate it back. literally genius shit here, god damn
		var basis_rotated_torque = current_transform.basis.inverse() * torque
		var basis_rotated_iner = basis_rotated_torque * og_inertia
		var rescaled_torque = current_transform.basis * basis_rotated_iner
		
		rescaled_torque = rescaled_torque.limit_length(max_angular_force)
		
		if b.name == "mixamorig_Hips":
			#print("DIFF ", rotation_difference.get_euler())
			#print("VELO ", b.angular_velocity)
			#print("INER ", )
			#print("FORC", rescaled_torque)
			pass
		
		b.apply_torque(rescaled_torque)
		accum_diff += clamp(target_transform.basis.get_rotation_quaternion().angle_to(current_transform.basis.get_rotation_quaternion()), 0, 1)
	
	# Scale animations by how close to matching we are
	accum_diff /= get_child_count()	
	anims.speed_scale = clampf(1 - accum_diff, 0.1, 1)
	print(anims.speed_scale)

# Critically damped spring
func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float) -> Vector3:
	return stiffness * displacement - 2 * (sqrt(stiffness) * current_velocity)
	
