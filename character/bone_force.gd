extends Node

@export var target_forcer: RigidBody3D
@export var target_skeleton: Skeleton3D

@export var spring_stiffness: float = 1200.0
@export var max_linear_force: float = 9999.0

@export var max_angular_force: float = 9999.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	for b in get_children():
		if b is not RigidBody3D or b.freeze or b.name.begins_with("i_"):
			continue
			
		var target_bone_id = target_skeleton.find_bone(b.name)
		
		var target_transform: Transform3D = target_skeleton.global_transform * target_skeleton.get_bone_global_pose(target_bone_id)
		var current_transform: Transform3D = b.get_node("CSGBox3D").global_transform
		var size = b.get_node("CSGBox3D").size

		var rotation_difference := target_transform.basis * current_transform.basis.inverse()
		var position_difference:Vector3 = target_transform.origin - (current_transform.origin  + Vector3(0, -size.y/2, 0) * current_transform.basis)
		
		#if position_difference.length_squared() > 1.0:
			#b.global_position = target_transform.origin
		#else:
		var force: Vector3 = hookes_law(position_difference, b.linear_velocity, spring_stiffness, b.mass)
		force = force.limit_length(max_linear_force) + position_difference
		b.apply_force(force)
		#target_forcer.apply_force(-force)
	
		#if b.name == "mixamorig_RightUpLeg":
			#print("DIFF ", rotation_difference.get_euler())
			#print("VELO ", b.angular_velocity)
			
		var torque = hookes_law(rotation_difference.get_euler(), b.angular_velocity, spring_stiffness, b.mass) / 100
		torque = torque.limit_length(max_angular_force)
		
		b.angular_velocity += (torque)
		#target_forcer.apply_torque(-torque)
#
func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, mass: float) -> Vector3:
	return stiffness * displacement - 2 * (sqrt(stiffness * mass) * current_velocity)
	

#func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, mass: float) -> Vector3:
	#return stiffness * displacement - (80 * current_velocity)
	#
