extends Node

@export var target_forcer: RigidBody3D
@export var target_skeleton: Skeleton3D

@export var linear_spring_stiffness: float = 1200.0
@export var linear_spring_damping: float = 40.0
@export var max_linear_force: float = 9999.0

@export var angular_spring_stiffness: float = 4000.0
@export var angular_spring_damping: float = 80.0
@export var max_angular_force: float = 9999.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	for b in get_children():
		if b is not RigidBody3D or b.freeze or b.name.begins_with("mixamorig_LeftSL"):
			continue
			
		var target_bone_id = target_skeleton.find_bone(b.name)
		
		var target_transform: Transform3D = target_skeleton.global_transform * target_skeleton.get_bone_global_pose(target_bone_id)
		var current_transform: Transform3D = b.get_node("CSGBox3D").global_transform
		var rotation_difference: Basis = (target_transform.basis * current_transform.basis.inverse())

		var size = b.get_node("CSGBox3D").size

		var position_difference:Vector3 = target_transform.origin - (current_transform.origin + Vector3(0, -size.y/2, 0) * current_transform.basis)
		
		#if position_difference.length_squared() > 1.0:
			#b.global_position = target_transform.origin
		#else:
		var force: Vector3 = hookes_law(position_difference, b.linear_velocity, linear_spring_stiffness, linear_spring_damping)
		force = force.limit_length(max_linear_force)
		b.linear_velocity += (force * delta)
			
		target_forcer.linear_velocity -= (force * delta)
	
		var torque = hookes_law(rotation_difference.get_euler(), b.angular_velocity, angular_spring_stiffness, angular_spring_damping)
		torque = torque.limit_length(max_angular_force)
		
		b.angular_velocity += torque * delta
		#target_forcer.angular_velocity -=torque * delta

func hookes_law(displacement: Vector3, current_velocity: Vector3, stiffness: float, damping: float) -> Vector3:
	return (stiffness * displacement) - (damping * current_velocity)
