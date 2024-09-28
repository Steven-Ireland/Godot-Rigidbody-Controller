extends Node

@export var target_forcer: RigidBody3D
@export var target_skeleton: Skeleton3D

@export var spring_stiffness: float = 1200.0
@export var max_angular_force: float = 9999.0

@export var anims: AnimationTree

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var accum_diff = 0.0
	
	for b in get_children():
		if b is not RigidBody3D or b.freeze or b.name.begins_with("i_"):
			continue
					
		#var height = b.global_position.y - get_lowest_bone().position.y
		var target_transform: Transform3D = get_bone_pose(b.name)
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
		
		if b.name == "mixamorig_Spine":
			#print("DIFF ", rotation_difference.get_euler())
			#print("VELO ", b.angular_velocity)
			#print("INER ", )
			#print("FORC", rescaled_torque)
			pass
		
		b.apply_torque(rescaled_torque)
		
		if not b.name.contains("Toe"):
			accum_diff += clamp(target_transform.basis.get_rotation_quaternion().angle_to(current_transform.basis.get_rotation_quaternion()), 0, 1)
	
	# Scale animations by how close to matching we are
	accum_diff /= (get_child_count() - 2)	
	var anim_speed = clampf(1 - accum_diff , 0.1, 1)
	
	anims.set("parameters/time_scale/scale", anim_speed)
	print(anim_speed)

func get_bone_pose(name):
	return target_skeleton.get_bone_global_pose(target_skeleton.find_bone(name)).rotated(Vector3.UP,target_skeleton.rotation.y)

func get_lowest_bone():
	var c = get_children()
	c.sort_custom(func(a,b): return a.global_position.y < b.global_position.y)
	
	return c[0]

# Critically damped spring
func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float) -> Vector3:
	return stiffness * displacement - 1 * (sqrt(stiffness) * current_velocity)
	
